import wave
import math
import struct

def generate_beep(filename, freq, duration_sec, sample_rate=44100):
    n_samples = int(duration_sec * sample_rate)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(n_samples):
            envelope = 1.0
            if i < 400: envelope = i / 400.0
            if i > n_samples - 400: envelope = (n_samples - i) / 400.0
            
            # exponential decay for a percussive "tak" click
            envelope *= math.exp(-15.0 * i / sample_rate)
            
            value = int(envelope * 32767.0 * 0.5 * math.sin(2.0 * math.pi * freq * i / sample_rate))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

# "Tak" click sound (short low frequency pop)
generate_beep("d:\\puzzle\\assets\\click.wav", 1200, 0.05)

# Victory sound (arpeggio)
with wave.open("d:\\puzzle\\assets\\win.wav", 'w') as wav_file:
    sample_rate = 44100
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    
    notes = [(523.25, 0.1), (659.25, 0.1), (783.99, 0.1), (1046.50, 0.4)]
    for freq, duration in notes:
        n_samples = int(duration * sample_rate)
        for i in range(n_samples):
            envelope = 1.0
            if i < 400: envelope = i / 400.0
            if i > n_samples - 400: envelope = (n_samples - i) / 400.0
            value = int(envelope * 32767.0 * 0.5 * math.sin(2.0 * math.pi * freq * i / sample_rate))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)
