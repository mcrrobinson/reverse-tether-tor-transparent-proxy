/*
 * Copyright (C) 2017 Genymobile
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.genymobile.gnirehtet.relay;

import java.nio.ByteBuffer;

@SuppressWarnings("checkstyle:MagicNumber")
public class TCPHeader implements TransportHeader {

    public static final int FLAG_FIN = 1 << 0;
    public static final int FLAG_SYN = 1 << 1;
    public static final int FLAG_RST = 1 << 2;
    public static final int FLAG_PSH = 1 << 3;
    public static final int FLAG_ACK = 1 << 4;
    public static final int FLAG_URG = 1 << 5;

    private final ByteBuffer raw;
    private int sourcePort;
    private int destinationPort;
    private int headerLength;
    private int sequenceNumber;
    private int acknowledgementNumber;
    private int flags;
    private int window;

    public TCPHeader(ByteBuffer raw) {
        this.raw = raw;
        sourcePort = Short.toUnsignedInt(raw.getShort(0));
        destinationPort = Short.toUnsignedInt(raw.getShort(2));

        sequenceNumber = raw.getInt(4);
        acknowledgementNumber = raw.getInt(8);

        short dataOffsetAndFlags = raw.getShort(12);
        headerLength = (dataOffsetAndFlags & 0xf000) >> 10;
        flags = dataOffsetAndFlags & 0x1ff;

        window = Short.toUnsignedInt(raw.getShort(14));

        raw.limit(headerLength);
    }

    public int getWindow() {
        return window;
    }

    @Override
    public int getSourcePort() {
        return sourcePort;
    }

    @Override
    public int getDestinationPort() {
        return destinationPort;
    }

    @Override
    public void setSourcePort(int sourcePort) {
        this.sourcePort = sourcePort;
        raw.putShort(0, (short) sourcePort);
    }

    @Override
    public void setDestinationPort(int destinationPort) {
        this.destinationPort = destinationPort;
        raw.putShort(2, (short) destinationPort);
    }

    public int getSequenceNumber() {
        return sequenceNumber;
    }

    public void setSequenceNumber(int sequenceNumber) {
        this.sequenceNumber = sequenceNumber;
        raw.putInt(4, sequenceNumber);
    }

    public int getAcknowledgementNumber() {
        return acknowledgementNumber;
    }

    public void setAcknowledgementNumber(int acknowledgementNumber) {
        this.acknowledgementNumber = acknowledgementNumber;
        raw.putInt(8, acknowledgementNumber);
    }

    @Override
    public int getHeaderLength() {
        return headerLength;
    }

    @Override
    public void setPayloadLength(int payloadLength) {
        // do nothing
    }

    public int getFlags() {
        return flags;
    }

    public void setFlags(int flags) {
        this.flags = flags;
        short dataOffsetAndFlags = raw.getShort(12);
        dataOffsetAndFlags = (short) (dataOffsetAndFlags & 0xfe00 | flags & 0x1ff);
        raw.putShort(12, dataOffsetAndFlags);
    }

    public void shrinkOptions() {
        setDataOffset(5);
        raw.limit(20);
    }

    private void setDataOffset(int dataOffset) {
        short dataOffsetAndFlags = raw.getShort(12);
        dataOffsetAndFlags = (short) (dataOffsetAndFlags & 0x0fff | (dataOffset << 12));
        raw.putShort(12, dataOffsetAndFlags);
        headerLength = dataOffset << 2;
    }

    public boolean isFin() {
        return (flags & FLAG_FIN) != 0;
    }

    public boolean isSyn() {
        return (flags & FLAG_SYN) != 0;
    }

    public boolean isRst() {
        return (flags & FLAG_RST) != 0;
    }

    public boolean isPsh() {
        return (flags & FLAG_PSH) != 0;
    }

    public boolean isAck() {
        return (flags & FLAG_ACK) != 0;
    }

    public boolean isUrg() {
        return (flags & FLAG_URG) != 0;
    }

    @Override
    public ByteBuffer getRaw() {
        raw.rewind();
        return raw.slice();
    }

    @Override
    public TCPHeader copyTo(ByteBuffer target) {
        raw.rewind();
        ByteBuffer slice = Binary.slice(target, target.position(), getHeaderLength());
        target.put(raw);
        return new TCPHeader(slice);
    }

    public TCPHeader copy() {
        return new TCPHeader(Binary.copy(raw));
    }

    @Override
    public void computeChecksum(IPv4Header ipv4Header, ByteBuffer payload) {
        // checksum computation is the most CPU-intensive task in gnirehtet
        // prefer optimization over readability
        byte[] rawArray = raw.array();
        int rawOffset = raw.arrayOffset();

        byte[] payloadArray = payload.array();
        int payloadOffset = payload.arrayOffset();

        // pseudo-header checksum (cf rfc793 section 3.1)

        int source = ipv4Header.getSource();
        int destination = ipv4Header.getDestination();
        int length = ipv4Header.getTotalLength() - ipv4Header.getHeaderLength();
        assert (length & ~0xffff) == 0 : "Length cannot take more than 16 bits"; // by design

        int sum = source >>> 16;
        sum += source & 0xffff;
        sum += destination >>> 16;
        sum += destination & 0xffff;
        sum += IPv4Header.Protocol.TCP.getNumber();
        sum += length;

        // reset checksum field
        setChecksum((short) 0);

        for (int i = 0; i < headerLength / 2; ++i) {
            // compute a 16-bit value from two 8-bit values manually
            sum += ((rawArray[rawOffset + 2 * i] & 0xff) << 8) | (rawArray[rawOffset + 2 * i + 1] & 0xff);
        }

        int payloadLength = length - headerLength;
        assert payloadLength == payload.limit() : "Payload length does not match";
        for (int i = 0; i < payloadLength / 2; ++i) {
            // compute a 16-bit value from two 8-bit values manually
            sum += ((payloadArray[payloadOffset + 2 * i] & 0xff) << 8) | (payloadArray[payloadOffset + 2 * i + 1] & 0xff);
        }
        if (payloadLength % 2 != 0) {
            sum += (payloadArray[payloadOffset + payloadLength - 1] & 0xff) << 8;
        }

        while ((sum & ~0xffff) != 0) {
            sum = (sum & 0xffff) + (sum >> 16);
        }
        setChecksum((short) ~sum);
    }

    private void setChecksum(short checksum) {
        raw.putShort(16, checksum);
    }

    public short getChecksum() {
        return raw.getShort(16);
    }
}
