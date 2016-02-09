package 
{
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.consts.Easing;
	import com.luaye.console.C;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.data.EncryptedLocalStore;
	
	import com.myflashlab.air.extensions.gcm.Gcm;
	import com.myflashlab.air.extensions.gcm.GcmEvent;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 7/13/2015 6:35 PM
	 */
	public class Main extends Sprite 
	{
		private var _ex:Gcm;
		
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		public function Main():void 
		{
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			C.startOnStage(this, "`");
			C.commandLine = false;
			C.commandLineAllowed = false;
			C.x = 100;
			C.width = 500;
			C.height = 250;
			C.strongRef = true;
			C.visible = true;
			C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
			
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.antiAliasType = AntiAliasType.ADVANCED;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.embedFonts = false;
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'>GCM Extension V" + Gcm.VERSION + " for adobe air projects!</font>";
			_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			this.addChild(_txt);
			
			_body = new Sprite();
			this.addChild(_body);
			
			_list = new List();
			_list.holder = _body;
			_list.itemsHolder = new Sprite();
			_list.orientation = Orientation.VERTICAL;
			_list.hDirection = Direction.LEFT_TO_RIGHT;
			_list.vDirection = Direction.TOP_TO_BOTTOM;
			_list.space = BTN_SPACE;
			
			init();
			onResize();
		}
		
		private function onInvoke(e:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
			
			// on iOS, you will receive the GCM message as an object containing a parameter named "aps" which holds a string.
			// it's your job to parse that string and read it's information OR you can simply wait for the GcmEvent.MESSAGE event
			// to be called which 'usually' happen on iOS side when user opens the app by clicking the notification
			
			if (e.arguments.length > 0)
			{
				C.log("The app has been run by clicking on the notification: ");
				
				try
				{
					var obj:Object = e.arguments[0];
					
					if (obj.aps)// we understand that this is coming for iOS
					{
						// extract the information we need. we are sending the gcm message including an "info" node. so we can get the "info" value like this.
						C.log("info = " + e.arguments[0]["gcm.notification.info"]);
					}
				}
				catch (err:Error)// if it's not iOS, then it surely is Android
				{
					var arr:Array = String(e.arguments[0]).split("://");
					C.log("info = " + decodeURI(arr[1]));
				}
			}
		}
		
		private function handleActivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		private function handleDeactivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
		
		private function handleKeys(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK)
            {
				e.preventDefault();
				NativeApplication.nativeApplication.exit();
            }
		}
		
		private function onResize(e:*=null):void
		{
			if (_txt)
			{
				_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				
				C.x = 0;
				C.y = 10 + _txt.y + _txt.height * (1 / DeviceInfo.dpiScaleMultiplier);
				C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				C.height = 300 * (1 / DeviceInfo.dpiScaleMultiplier);
			}
			
			if (_list)
			{
				_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
				_list.row = _numRows;
				_list.itemArrange();
			}
			
			if (_body)
			{
				_body.y = stage.stageHeight - _body.height;
			}
		}
		
		private function init():void
		{
			// required only if you are a member of the club
			Gcm.clubId = "paypal-address-you-used-to-join-the-club";
			
			// set this to false when you are using your production certificate. (this property must be set before you initialize the extension with new Gcm(...)
			Gcm.isSandbox = true;
			
			// http://myflashlabs.com/showcase/AIR_EXTENSIONS/GCM/demoV4/
			_ex = new Gcm(ANDROID_SENDERID, IOS_SENDERID);
			_ex.addEventListener(GcmEvent.REGISTERED, onRegIdReceived);
			_ex.addEventListener(GcmEvent.UNREGISTERED, onUnregistered);
			_ex.addEventListener(GcmEvent.ERROR, onError);
			_ex.addEventListener(GcmEvent.MESSAGE, onMessage);
			
			var btn1:MySprite = createBtn("getRegId");
			btn1.addEventListener(MouseEvent.CLICK, toGetRegistrationId);
			_list.add(btn1);
			
			function toGetRegistrationId(e:MouseEvent):void
			{
				C.log("regId = " + _ex.getRegId);
				trace("regId = " + _ex.getRegId);
			}
			
			var btn2:MySprite = createBtn("register");
			btn2.addEventListener(MouseEvent.CLICK,  toRegister);
			_list.add(btn2);
			
			function toRegister(e:MouseEvent):void
			{
				C.log("to register...");
				_ex.register();
			}
			
			var btn3:MySprite = createBtn("unregister");
			btn3.addEventListener(MouseEvent.CLICK,  toUnregister);
			_list.add(btn3);
			
			function toUnregister(e:MouseEvent):void
			{
				C.log("to unregister...");
				_ex.unregister();
			}
			
			var btn4:MySprite = createBtn("openIOSAppSettings");
			btn4.addEventListener(MouseEvent.CLICK,  openIOSAppSettings);
			_list.add(btn4);
			
			function openIOSAppSettings(e:MouseEvent):void
			{
				_ex.openIOSAppSettings();
			}
			
			var btn5:MySprite = createBtn("getOSVersion");
			btn5.addEventListener(MouseEvent.CLICK,  getOSVersion);
			_list.add(btn5);
			
			function getOSVersion(e:MouseEvent):void
			{
				C.log("getOSVersion = " + _ex.getOSVersion());
			}
			
			var btn6:MySprite = createBtn("getBadge");
			btn6.addEventListener(MouseEvent.CLICK, getBadge);
			_list.add(btn6);
			
			function getBadge(e:MouseEvent):void
			{
				// Android does not support badges and will returns -1
				C.log("current badge = " + _ex.badge);
			}
			
			var btn7:MySprite = createBtn("set badge to: 0");
			btn7.addEventListener(MouseEvent.CLICK, setBadge);
			_list.add(btn7);
			
			function setBadge(e:MouseEvent):void
			{
				C.log(">> change badge to any int <<");
				_ex.badge = 0;
			}
			
			
		}
		
		private function onError(e:GcmEvent):void
		{
			C.log("onError: ", e.param);
		}
		
		private function onRegIdReceived(e:GcmEvent):void
		{
			C.log("onRegistered: ", e.param);
		}
		
		private function onUnregistered(e:GcmEvent):void
		{
			C.log("onUnregistered: ", e.param);
		}
		
		private function onMessage(e:GcmEvent):void
		{
			C.log("onMessage: ", e.param);
			trace("onMessage: ", e.param);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function createBtn($str:String):MySprite
		{
			var sp:MySprite = new MySprite();
			sp.addEventListener(MouseEvent.MOUSE_OVER,  onOver);
			sp.addEventListener(MouseEvent.MOUSE_OUT,  onOut);
			sp.addEventListener(MouseEvent.CLICK,  onOut);
			sp.bgAlpha = 1;
			sp.bgColor = 0xDFE4FF;
			sp.drawBg();
			sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
			sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
			
			function onOver(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xFFDB48;
				sp.drawBg();
			}
			
			function onOut(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xDFE4FF;
				sp.drawBg();
			}
			
			var format:TextFormat = new TextFormat("Arimo", 16, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
			
			var txt:TextField = new TextField();
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.antiAliasType = AntiAliasType.ADVANCED;
			txt.mouseEnabled = false;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
			txt.defaultTextFormat = format;
			txt.text = $str;
			
			txt.y = sp.height - txt.height >> 1;
			sp.addChild(txt);
			
			return sp;
		}
	}
	
}