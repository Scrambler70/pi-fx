from gpiozero import Button
import mido
import time

btn_sl_record = Button(19)
btn_sl_reset = Button(20)
btn_sl_pause = Button(12)
outport = mido.open_output()
recording = 0
loop_complete = 0
reset = 0
pause = 0
overdub = 0
response = "null"


midi_msg_record_on = mido.Message('note_on', note=36)
midi_msg_record_off= mido.Message('note_off', note=36)
midi_msg_overdub_on = mido.Message('note_on', note=37)
midi_msg_overdub_off = mido.Message('note_off', note=37)
midi_msg_pause_on = mido.Message('note_on',note=38)
midi_msg_pause_off = mido.Message('note_off',note=38)
midi_msg_reset_on = mido.Message('note_on',note=46)
midi_msg_reset_off = mido.Message('note_off',note=46)

while True:

	if btn_sl_record.is_pressed:
		if loop_complete == 0:
			if recording == 1:
				recording = 0
				outport.send(midi_msg_record_off)
				response = "recording off "
				print(response)
				btn_sl_record.wait_for_release()
				loop_complete = 1

			else:
				recording = 1
				outport.send(midi_msg_record_on)
				response = "recording on "
				print(response)
				btn_sl_record.wait_for_release()
		else:
			if overdub == 0:
				overdub = 1
				outport.send(midi_msg_overdub_on)
				response = "overdub on"
				print(response)
				btn_sl_record.wait_for_release()
			else:
				overdub = 0
				outport.send(midi_msg_overdub_off)
				response = "overdub off"
				print(response)
				btn_sl_record.wait_for_release()

	if btn_sl_reset.is_pressed:
		outport.send(midi_msg_reset_on)
		response = "reset"
		print(response)
		time.sleep(0.05)
		btn_sl_reset.wait_for_release()
		outport.send(midi_msg_reset_off)
		overdub = 0
		loop_complete =0

	if btn_sl_pause.is_pressed:

		if pause == 1:
			pause = 0
			outport.send(midi_msg_pause_off)
			response = "pause off"
			print(response)
			btn_sl_pause.wait_for_release()

		else:
			playing = 1
			outport.send(midi_msg_pause_on)
			response = "pause on "
			print(response)
			btn_sl_pause.wait_for_release()
	time.sleep(0.02)






