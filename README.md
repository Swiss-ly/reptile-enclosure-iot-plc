# Reptile enclosure maintenance system (IoT and PLC)

An IoT system that keeps a snake enclosure's humidity, temperature and lighting within safe ranges with minimal supervision. Individual university coursework, April 2025.

Node-RED handles the logic and the operator interface, OpenPLC drives the outputs, and three protocols connect the parts: MQTT for incoming sensor data, Modbus TCP between Node-RED and the PLC, and HTTP to log enclosure status to an external web service.

<img width="897" height="405" alt="image" src="https://github.com/user-attachments/assets/e6d946af-8a0e-47a5-a9e6-cddb6936dbbe" />


## What's here

| Path | Contents |
|---|---|
| `src/flows.json` | The Node-RED flows: MQTT ingestion, control logic, dashboard HMI, HTTP upload |
| `src/enclosure_control.st` | The OpenPLC program, exported as IEC 61131-3 Structured Text from the ladder logic |

The design report and work logs are not included.

## What the system does

- Runs a mist sprayer when humidity drops below 50% RH: a 10-second spray, then a 5-minute lockout between automatic sprays.
- Switches a heat source to hold the warm side at 27 to 29 °C.
- Scales the enclosure LED brightness to follow outdoor light through the day.
- Logs enclosure status hourly to an external service, and skips the upload if any value is undefined.
- Shows live status on a Node-RED Dashboard HMI, with an auto/manual switch for each function and manual override of any PLC action.

## How it is built

**PLC (OpenPLC, 20 ms task cycle)**
- Start/stop latching circuits for the heat source and the mist sprayer.
- Software PWM for LED dimming: a 0 to 99 counter incremented every scan and compared against a duty-cycle register. The counter was moved from Node-RED into the PLC during the build, which cut Modbus traffic and steadied the signal.

**Node-RED**
- MQTT ingestion with payload decoding and scaling to engineering units.
- Automatic control evaluated every second, writing to PLC coils over Modbus TCP.
- Auto/manual mode held in global state and checked before either path acts, so manual commands and automatic control never conflict.
- A switch between live MQTT data and a test dataset.

**Design work behind it**
- Hardware specification: DHT22 sensor, a light-dependent resistor in a voltage divider, an MCP3004 10-bit ADC, with the divider output and ADC range calculated.
- Protocol comparison (MQTT against AMQP and CoAP) and a Modbus address map.
- A security risk evaluation of the three protocols.

## Running it

1. Import `src/flows.json` into Node-RED, with `node-red-dashboard` and `node-red-contrib-modbus` installed.
2. Load `src/enclosure_control.st` into OpenPLC on the same machine. Node-RED expects the PLC's Modbus server at `127.0.0.1:502`.
3. The MQTT nodes use placeholder Things Network application names and no credentials are included, so live data needs your own broker settings. The test dataset works without them.
4. The status upload points at a placeholder address (`https://example.com/upload`) and sends an ID field set to `0`; change both to use a real logging service.

## Known limitations

- Built and tested on a virtual Raspberry Pi with simulated and test-feed inputs. The enclosure hardware was specified, not built.
- The mist sprayer output only switches the servo's power; servo angle control is not implemented.
- The security recommendations from the design work (TLS, strong credentials, restricted physical access) were not implemented.
