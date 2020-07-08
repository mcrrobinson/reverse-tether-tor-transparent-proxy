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

public class ConnectionId {

    private final IPv4Header.Protocol protocol;
    private final int sourceIp;
    private final short sourcePort;
    private final int destIp;
    private final short destPort;
    private final String idString;

    public ConnectionId(IPv4Header.Protocol protocol, int sourceIp, short sourcePort, int destIp, short destPort) {
        this.protocol = protocol;
        this.sourceIp = sourceIp;
        this.sourcePort = sourcePort;
        this.destIp = destIp;
        this.destPort = destPort;

        // compute the String representation only once
        idString = protocol + " " + Net.toString(sourceIp, sourcePort) + " -> " + Net.toString(destIp, destPort);
    }

    public IPv4Header.Protocol getProtocol() {
        return protocol;
    }

    public int getSourceIp() {
        return sourceIp;
    }

    public int getSourcePort() {
        return Short.toUnsignedInt(sourcePort);
    }

    public int getDestinationIp() {
        return destIp;
    }

    public int getDestinationPort() {
        return Short.toUnsignedInt(destPort);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }

        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        ConnectionId that = (ConnectionId) o;
        return sourceIp == that.sourceIp
                && sourcePort == that.sourcePort
                && destIp == that.destIp
                && destPort == that.destPort
                && protocol == that.protocol;
    }

    @Override
    public int hashCode() {
        int result = protocol.hashCode();
        result = 31 * result + sourceIp;
        result = 31 * result + (int) sourcePort;
        result = 31 * result + destIp;
        result = 31 * result + (int) destPort;
        return result;
    }

    @Override
    public String toString() {
        return idString;
    }

    public static ConnectionId from(IPv4Header ipv4Header, TransportHeader transportHeader) {
        IPv4Header.Protocol protocol = ipv4Header.getProtocol();
        int sourceAddress = ipv4Header.getSource();
        short sourcePort = (short) transportHeader.getSourcePort();
        int destinationAddress = ipv4Header.getDestination();
        short destinationPort = (short) transportHeader.getDestinationPort();
        return new ConnectionId(protocol, sourceAddress, sourcePort, destinationAddress, destinationPort);
    }
}
