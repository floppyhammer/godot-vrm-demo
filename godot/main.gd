extends Node3D

@onready var lip_sync = $LipSync
var is_talking = false
var playing_time = 0
const SAMPLE_INTERVAL = 0.1
var last_time_updated = 0

var precision_threshold = 0.8

@export var target_avatar_path: NodePath
var target_avatar: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	target_avatar = get_node(target_avatar_path)


func _process(delta):
	$CanvasLayer/Fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
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
	if target_avatar == null:
		return
		
	var anim_player: AnimationPlayer = target_avatar.get_node("AnimationPlayer")
	
	if output["amount"] > precision_threshold:
		var transition_time = 0
		
		match output["vowel"]:
			0:
				anim_player.play("aa", transition_time)
				$CanvasLayer/Estimate.text = "A"
			1:
				anim_player.play("ih", transition_time)
				$CanvasLayer/Estimate.text = "E"
			2:
				anim_player.play("ou", transition_time)
				$CanvasLayer/Estimate.text = "U"
			3:
				anim_player.play("ee", transition_time)
				$CanvasLayer/Estimate.text = "E"
			4:
				anim_player.play("oh", transition_time)
				$CanvasLayer/Estimate.text = "O"
		
		$CanvasLayer/Estimate.text += ": %.2f" % output["amount"]
	else:
		anim_player.play("custom/reset_morph")
		#anim_player.advance(0)
		$CanvasLayer/Estimate.text = "_"


# reference (https://godotengine.org/qa/67091/how-to-read-audio-samples-as-1-1-floats) 
static func read_16bit_samples(stream: AudioStreamWAV, time: float, duration: float) -> Array:
	assert(stream.format == AudioStreamWAV.FORMAT_16_BITS)
	var bytes = stream.data
	var samples: Array[float] = []
	
	var is_stereo = stream.is_stereo()
	var channel_count = 2 if is_stereo else 1
	
	var sampling_start: int = round(time * stream.mix_rate * 2 * channel_count)
	var sampling_end: int = sampling_start + round(duration * stream.mix_rate * 2 * channel_count)
	
	var i = sampling_start
	
	# Read by packs of 2 + 2 bytes
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
		# 16-bit and stereo
		i += 2 * channel_count

	return samples


func _on_start_talking_pressed():
	is_talking = true
	$AudioStreamPlayer.play()
