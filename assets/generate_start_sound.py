import wave
import math
import struct

def generate_sweep(filename, start_freq, end_freq, duration_sec, sample_rate=44100):
    n_samples = int(duration_sec * sample_rate)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(n_samples):
            # Envelop
            envelope = 1.0
            if i < 400: envelope = i / 400.0
            if i > n_samples - 400: envelope = (n_samples - i) / 400.0
            
            # Frequency sweep
            t = i / sample_rate
            current_freq = start_freq + (end_freq - start_freq) * (t / duration_sec)
            
            value = int(envelope * 32767.0 * 0.3 * math.sin(2.0 * math.pi * current_freq * t))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

# "Start" sound (quick upward sweep)
generate_sweep("d:\\puzzle\\assets\\start.wav", 400, 800, 0.2)
