import wave
import math
import struct

def generate_error_sound(filename, start_freq, end_freq, duration_sec, sample_rate=44100):
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
            
            # Frequency sweep downwards
            t = i / sample_rate
            current_freq = start_freq + (end_freq - start_freq) * (t / duration_sec)
            
            # Use a slight square wave mixed with sine for a "buzz" error feel
            sine_val = math.sin(2.0 * math.pi * current_freq * t)
            square_val = 1.0 if sine_val > 0 else -1.0
            mixed_val = (sine_val * 0.5) + (square_val * 0.5)
            
            value = int(envelope * 32767.0 * 0.3 * mixed_val)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

# "Error" sound (quick downward sweep buzz)
generate_error_sound("d:\\puzzle\\assets\\error.wav", 150, 80, 0.25)
