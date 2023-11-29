extends Node3D

@onready var lip_sync = $LipSync
var is_talking = false
var playing_time = 0
const SAMPLE_INTERVAL = 0.2
var last_time_updated = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	if is_talking:
		if (playing_time - last_time_updated) > SAMPLE_INTERVAL:
			var audio_data = read_16bit_samples($AudioStreamPlayer.stream, playing_time, SAMPLE_INTERVAL)
			lip_sync.update(audio_data)
			last_time_updated = playing_time
		
		playing_time += delta
	
	lip_sync.poll()


func _on_lip_sync_panicked(error: String):
	print(error)


func _on_lip_sync_updated(output: Dictionary):
	$Furina/AnimationPlayer.play("RESET")
	
	match output["vowel"]:
		0:
			$Furina/AnimationPlayer.play("aa", output["amount"])
		1:
			$Furina/AnimationPlayer.play("ih", output["amount"])
		2:
			$Furina/AnimationPlayer.play("ou", output["amount"])
		3:
			$Furina/AnimationPlayer.play("ee", output["amount"])
		4:
			$Furina/AnimationPlayer.play("oh", output["amount"])
	print(output)


# reference (https://godotengine.org/qa/67091/how-to-read-audio-samples-as-1-1-floats) 
static func read_16bit_samples(stream: AudioStreamWAV, time: float, duration: float) -> Array:
	assert(stream.format == AudioStreamWAV.FORMAT_16_BITS)
	var bytes = stream.data
	var samples: Array[float] = []
	
	var sampling_start = time * stream.mix_rate * 2 * 2
	var sampling_end = sampling_start + duration * stream.mix_rate * 2 * 2
	
	var i = sampling_start
	
	# Read by packs of 2 bytes
	while i < len(bytes) and i < sampling_end:
		var b0 = bytes[i]
		var b1 = bytes[i + 1]
		# Combine low bits and high bits to obtain 16-bit value
		var u = b0 | (b1 << 8)
		# Emulate signed to unsigned 16-bit conversion
		u = (u + 32768) & 0xffff
		# Convert to -1..1 range
		var s = float(u - 32768) / 32768.0
		samples.append(s)
		i += 2
	return samples


func _on_start_talking_pressed():
	is_talking = true
	$AudioStreamPlayer.play()
