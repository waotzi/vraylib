module main

import os
import waotzi.vraylib
import rand

const (
	screen_width  = 800
	screen_height = 450
	max_circles   = 64
)

struct CircleWave {
pub mut:
	position C.Vector2
	radius   f32
	alpha    f32
	speed    f32
	color    C.Color
}

fn main() {
	vraylib.init_window(screen_width, screen_height, 'vraylib [audio] example - module playing (streaming)')
	vraylib.init_audio_device()
	vraylib.set_target_fps(60)

	colors := [
		vraylib.orange,
		vraylib.red,
		vraylib.gold,
		vraylib.lime,
		vraylib.blue,
		vraylib.violet,
		vraylib.brown,
		vraylib.lightgray,
		vraylib.pink,
		vraylib.yellow,
		vraylib.green,
		vraylib.skyblue,
		vraylib.purple,
		vraylib.beige,
	]

	mut circles := [max_circles]CircleWave{}

	for i := 0; i < max_circles; i++ {
		circles[i].alpha = 0.0
		circles[i].radius = rand.int_in_range(10, 40)
		circles[i].position.x = rand.int_in_range(int(circles[i].radius), screen_width - int(circles[i].radius))
		circles[i].position.y = rand.int_in_range(int(circles[i].radius), screen_height - int(circles[i].radius))
		circles[i].speed = f32(rand.int_in_range(1, 100)) / 2000.0
		circles[i].color = colors[rand.int_in_range(0, 13)]
	}

	music := vraylib.load_music_stream('resources/mini1111.xm')
	vraylib.play_music_stream(music)
	mut time_played := 0.0
	mut pause := false

	for {
		if vraylib.window_should_close() {
			break
		}
		vraylib.update_music_stream(music)
		if vraylib.is_key_pressed(vraylib.key_p) {
			pause = !pause
			if pause {
				vraylib.pause_music_stream(music)
			} else {
				vraylib.resume_music_stream(music)
			}
		}
		time_played = vraylib.get_music_time_played(music) / vraylib.get_music_time_length(music) * (screen_width - 40)
		for i := max_circles - 1; i >= 0; i-- {
			circles[i].alpha += circles[i].speed
			circles[i].radius += circles[i].speed * 10.0

			if circles[i].alpha > 1.0 {
				circles[i].speed *= -1
			}

			if circles[i].alpha <= 0 {
				circles[i].alpha = 0.0
				circles[i].radius = rand.int_in_range(10, 40)
				circles[i].position.x = rand.int_in_range(int(circles[i].radius), screen_width - int(circles[i].radius))
				circles[i].position.y = rand.int_in_range(int(circles[i].radius), screen_height - int(circles[i].radius))
				circles[i].speed = f32(rand.int_in_range(1, 100)) / 2000.0
				circles[i].color = colors[rand.int_in_range(0, 13)]
			}
		}

		{
			vraylib.begin_drawing()
			for i := 39; i >= 0; i-- {
				vraylib.draw_circle_v(circles[i].position, circles[i].radius, vraylib.fade(circles[i].color,
					circles[i].alpha))
			}

			vraylib.draw_rectangle(20, screen_height - 20 - 12, screen_width - 40, 12,
				vraylib.lightgray)
			vraylib.draw_rectangle(20, screen_height - 20 - 12, int(time_played), 12,
				vraylib.maroon)
			vraylib.draw_rectangle_lines(20, screen_height - 20 - 12, screen_width - 40,
				12, vraylib.gray)

			vraylib.clear_background(vraylib.raywhite)
			vraylib.end_drawing()
		}
	}
	vraylib.unload_music_stream(music)
	vraylib.close_audio_device()
	vraylib.close_window()
}
