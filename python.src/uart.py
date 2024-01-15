import serial

class Uart():
    serial_port = None
    baudrate = None
    
    def __init__(self, serial_port, baudrate, parity = serial.PARITY_NONE, stopbits = serial.STOPBITS_ONE, bytesize = serial.EIGHTBITS):
        self.serial_port = serial_port
        self.baudrate = baudrate
        
        self.serial_port = serial.Serial(port=self.serial_port,
                                         baudrate=self.baudrate,
                                         parity=parity,
                                         stopbits=stopbits,
                                         bytesize=bytesize)
        
    def write(self, data, size=1, byteorder='little'):
        self.serial_port.write(int(data).to_bytes(size, byteorder=byteorder))
        
    def read(self, size=1, byteorder='little'):
        return int.from_bytes(self.serial_port.read(size), byteorder=byteorder)
    
    def available(self, bytes = 1):
        return self.serial_port.in_waiting >= bytes

    def flush(self):
        self.serial_port.reset_input_buffer()
        self.serial_port.reset_output_buffer()
        
    def close(self):
        self.serial_port.close()