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

import org.junit.Assert;
import org.junit.Test;

import java.nio.ByteBuffer;

@SuppressWarnings("checkstyle:MagicNumber")
public class IPv4PacketTest {

    private static ByteBuffer createMockPacket() {
        ByteBuffer buffer = ByteBuffer.allocate(32);

        buffer.put((byte) ((4 << 4) | 5)); // versionAndIHL
        buffer.put((byte) 0); // ToS
        buffer.putShort((short) 32); // total length 20 + 8 + 4
        buffer.putInt(0); // IdFlagsFragmentOffset
        buffer.put((byte) 0); // TTL
        buffer.put((byte) 17); // protocol (UDP)
        buffer.putShort((short) 0); // checksum
        buffer.putInt(0x12345678); // source address
        buffer.putInt(0x42424242); // destination address

        buffer.putShort((short) 1234); // source port
        buffer.putShort((short) 5678); // destination port
        buffer.putShort((short) 4); // length
        buffer.putShort((short) 0); // checksum

        buffer.putInt(0x11223344); // payload

        return buffer;
    }

    @Test
    public void testParseHeaders() {
        ByteBuffer buffer = createMockPacket();
        IPv4Packet packet = new IPv4Packet(buffer);

        IPv4Header ipv4Header = packet.getIpv4Header();
        Assert.assertTrue(ipv4Header.isSupported());
        Assert.assertEquals(20, ipv4Header.getHeaderLength());
        Assert.assertEquals(32, ipv4Header.getTotalLength());
        Assert.assertEquals(IPv4Header.Protocol.UDP, ipv4Header.getProtocol());
        Assert.assertEquals(0x12345678, ipv4Header.getSource());
        Assert.assertEquals(0x42424242, ipv4Header.getDestination());

        UDPHeader udpHeader = (UDPHeader) packet.getTransportHeader();
        Assert.assertEquals(1234, udpHeader.getSourcePort());
        Assert.assertEquals(5678, udpHeader.getDestinationPort());
        Assert.assertEquals(8, udpHeader.getHeaderLength());

        packet.swapSourceAndDestination();

        Assert.assertEquals(0x42424242, ipv4Header.getSource());
        Assert.assertEquals(0x12345678, ipv4Header.getDestination());
        Assert.assertEquals(5678, udpHeader.getSourcePort());
        Assert.assertEquals(1234, udpHeader.getDestinationPort());

        int source = buffer.getInt(12);
        int destination = buffer.getInt(16);
        int sourcePort = Short.toUnsignedInt(buffer.getShort(20));
        int destinationPort = Short.toUnsignedInt(buffer.getShort(22));

        Assert.assertEquals(0x42424242, source);
        Assert.assertEquals(0x12345678, destination);
        Assert.assertEquals(5678, sourcePort);
        Assert.assertEquals(1234, destinationPort);
    }

    @Test
    public void testPayload() {
        ByteBuffer buffer = createMockPacket();
        IPv4Packet packet = new IPv4Packet(buffer);

        ByteBuffer payload = packet.getPayload();
        Assert.assertEquals(0x11223344, payload.getInt(0));
    }
}
