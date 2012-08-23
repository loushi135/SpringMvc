package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.ActivityEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.net.FileReference;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import flash.net.URLRequest;
	import flash.display.SimpleButton;
	import flash.text.TextField;

	import Pitch;
	
	import cn.digitalland.media.sound.mp3.MP3Parser;
	import cn.digitalland.media.sound.shinemp3.ShineMP3Encoder;
	import cn.digitalland.media.sound.as3wavsound.WavSound;
	import cn.digitalland.media.sound.micrecorder.MicRecorder;
	import cn.digitalland.media.sound.micrecorder.encoder.WaveEncoder;
	import cn.digitalland.media.sound.micrecorder.events.RecordingEvent;
	/**
	 * ...
	 * @author hugang
	 */
	public class Record extends Sprite {
		private var volume:Number = 1; // volume in the final WAV file
		private var wavEncoder:WaveEncoder; // we create the WAV encoder to be used by MicRecorder
		private var recorder:MicRecorder; // we create the MicRecorder object which does the job

		//private var player:WavSound;  //mav格式
		private var player:ShineMP3Encoder;      //mp3格式
		private var _file:FileReference;

		private var _sound:Sound;
		private var _mp3:MP3Parser;//mp3数据转sound
		
		private var _pitch:Pitch;//声音变速
		
		//音波
		private var soundByteArray:ByteArray=new ByteArray();//字节数组
		private var soundNum:Number;
		private var soundLineColor:uint;
		
		private var dargFlag:Boolean = false;

		private var _this = this;
		
		public function Record(){
			wavEncoder = new WaveEncoder(volume);
			recorder = new MicRecorder(wavEncoder);
			recorder.addEventListener(RecordingEvent.RECORDING, onRecording);
			recorder.addEventListener(Event.COMPLETE, onRecordComplete);
			stage.addEventListener(Event.ENTER_FRAME,drawWave);
			//---------------------------------------------------------------------------------------------	
			enabledBtn(record_btn, recordLis);
			disabledBtn(stop_btn,stopLis);
			disabledBtn(play_btn, playLis);
			disabledBtn(save_btn, saveLis);
			//------------------------------------------------
			drag_btn.addEventListener(MouseEvent.MOUSE_DOWN, drag_down);
		}
		private function drag_down(event:Event):void {
			dargFlag = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, drag_up);
		}
		private function drag_up(event:Event):void {
			dargFlag = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, drag_up);
		}
		private function enabledBtn(btn:SimpleButton,lis) {
			btn.addEventListener(MouseEvent.CLICK, lis);
			btn.enabled = true;
		}
		private function disabledBtn(btn:SimpleButton,lis) {
			btn.removeEventListener(MouseEvent.CLICK, lis);
			btn.enabled = false;
		}
		private function onRecording(event:RecordingEvent):void {
			trace("Recording since : " + event.time + " ms.");
			//timetxt.text = String(event.time);
		}

		private function onRecordComplete(event:Event):void {
			//player = new WavSound(recorder.output);	
			player = new ShineMP3Encoder(recorder.output);
			player.start();
			player.addEventListener(Event.COMPLETE, makeEnd);
			player.addEventListener("start", makeStart);
			function makeStart(e:Event){
				//timetxt.text = "start";
			}
			function makeEnd(e:Event) {
				enabledBtn(play_btn, playLis);
				enabledBtn(save_btn, saveLis);
				enabledBtn(record_btn, recordLis);
				//timetxt.text = "complete";
			}
		}

		private function recordLis(e:MouseEvent) {
			disabledBtn(play_btn, playLis);
			disabledBtn(save_btn, saveLis);
			recorder.record();
			recorder.microphone.addEventListener(ActivityEvent.ACTIVITY, micStartLis);			
		}
		private function micStartLis(e:ActivityEvent) {
			disabledBtn(record_btn,recordLis);
			pro_mc.gotoAndPlay(2);
			pro_mc.addEventListener("RecordEnd", stopLis);
			enabledBtn(stop_btn,stopLis);
		}

		private function stopLis(e:*){
			recorder.stop();
			pro_mc.gotoAndStop(1);
			pro_mc.removeEventListener("RecordEnd", stopLis);
			disabledBtn(stop_btn,stopLis);
		}		
		private function playLis(e:MouseEvent){
			_mp3 = new MP3Parser();
			_mp3.loadFile(player.data);
			_mp3.addEventListener(Event.COMPLETE, loadEnd);
			//disabledBtn(play_btn,playLis);
			function loadEnd(e:Event){
				_sound = new Sound();
				_sound = _mp3.getSound();
				_pitch = new Pitch(_sound);
				_pitch.addEventListener("SoundPlayEnd", plaeEnd);
				var r = (drag_btn.x - 160) / 85;
				_pitch.rate = r > 1?r:(r + 1) / 2;
				//trace(_pitch.rate);
				//_sound.play();
			}
			//_sound = new Sound();
			//_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);
			//_sound.play();
		}
		private function plaeEnd(e:Event) {
			enabledBtn(play_btn, playLis);
		}
		private function saveLis(e:MouseEvent){
			_file = new FileReference();
			_file.save(player.data, "recorded.mp3");
			//_file.save(recorder.output, "recorded.wav");
		}
		private function drawWave(e:Event) {
			//soundLineColor = Math.random() * 0xFFFFFF;
			soundLineColor=0xFF0000;
			graphics.clear();
			graphics.lineStyle(1,soundLineColor);
			graphics.moveTo(10,400);
			SoundMixer.computeSpectrum(soundByteArray,false,0);
			for (var i=25; i<=475; i++) {
				soundNum=soundByteArray.readFloat() * 100;
				graphics.lineTo(i,soundNum+400);
			}
			//-------------------------------------
			if (!dargFlag) return;
			var dx:Number = stage.mouseX;
			drag_btn.x = (dx < 160)?160:((dx>330)?330:dx);
		}
		private function sampleData(event:SampleDataEvent):void {			
			//event.data.writeBytes(player.data);
			
			/*for ( var c:int=0; c<_mp3.length; c++ ) {
			   event.data.writeFloat(_mp3[c]);
			 }*/
			/*var bytes:ByteArray = player.data as ByteArray;
			while (bytes.bytesAvailable > 0){
				event.data.writeFloat(bytes[bytes.position]);
				event.data.writeFloat(bytes[bytes.position]);
				bytes.position += 1;
			}*/

		/* var bytes:ByteArray = new ByteArray();
		 _mp3.extract(bytes, 4096);
		 event.data.writeBytes(bytes);*/
		}
	}

}
