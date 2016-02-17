# GCM ANE V4.9.3 for Android+iOS
GCM ANE let's you use Google cloud messaging on Android and iOS to send push notifications (remote notifications) to your app users.

# Air Usage
```actionscript
import com.myflashlab.air.extensions.gcm.Gcm;
import com.myflashlab.air.extensions.gcm.GcmEvent;

// set this to false when you are using your production certificate. (this property must be set before you initialize the extension with new Gcm(...)
Gcm.isSandbox = true;

var _ex:Gcm = new Gcm(ANDROID_SENDER_ID, IOS_SENDER_ID);
_ex.addEventListener(GcmEvent.REGISTERED, onRegIdReceived);
_ex.addEventListener(GcmEvent.UNREGISTERED, onUnregistered);
_ex.addEventListener(GcmEvent.ERROR, onError);
_ex.addEventListener(GcmEvent.MESSAGE, onMessage);

trace("regId = " + _ex.getRegId); // will return null or an empty String if you have not registered yet

_ex.register();
//_ex.unregister();

function onError(e:GcmEvent):void
{
    trace("onError: ", e.param);
}

function onRegIdReceived(e:GcmEvent):void
{
    trace("onRegistered: ", e.param);
}

function onUnregistered(e:GcmEvent):void
{
    trace("onUnregistered: ", e.param);
}

function onMessage(e:GcmEvent):void
{
    trace("onMessage: ", e.param);
}
```

# Air Usage - InvokeEvent.INVOKE
```actionscript
NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);

private function onInvoke(e:InvokeEvent):void
{
	NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
	
	// on iOS, you will receive the GCM message as an object containing a parameter named "aps" which holds a string.
	// it's your job to parse that string and read it's information OR you can simply wait for the GcmEvent.MESSAGE event
	// to be called which 'usually' happen on iOS side when user opens the app by clicking the notification
	
	if (e.arguments.length > 0)
	{
		trace("The app has been run by clicking on the notification");
		
		try
		{
			var obj:Object = e.arguments[0];
			
			if (obj.aps)// we understand that this is coming for iOS
			{
				// extract the information we need. we are sending the gcm message including an "info" node. so we can get the "info" value like this.
				trace("info = " + e.arguments[0]["gcm.notification.info"]);
			}
		}
		catch (err:Error) // if it's not iOS, then it's Android.
		{
			var arr:Array = String(e.arguments[0]).split("://");
			trace(decodeURI(arr[1]));
		}
	}
}
```

# Air .xml manifest
```xml
<!--
FOR ANDROID:
-->
<manifest android:installLocation="auto">
			
			<!--
			
				IMPORTANT: change all "air.com.doitflash.gcm" to your own package name. (notice the air. at the beginning)
				if your package name is "com.site.app" Android automatically adds air. to its beginning. so your Android package
				name will be actually "air.com.site.app" but on the iOS, it is still "com.site.app" with no change
			
			-->
		
		<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
		
		<!-- Required for gcm access -->
		<uses-permission android:name="android.permission.INTERNET" />
		<uses-permission android:name="android.permission.GET_ACCOUNTS" />
		<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
		<permission android:name="air.com.doitflash.gcm.permission.C2D_MESSAGE" android:protectionLevel="signature" />
		<uses-permission android:name="air.com.doitflash.gcm.permission.C2D_MESSAGE" />
		
		<!-- Required for waking up the device when gcm msg is arrived -->
		<uses-permission android:name="android.permission.WAKE_LOCK" />
		
		<!-- if gcm tasks are set for future, you need this to make sure timers are all set even after user restarts their device -->
		<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
		<uses-permission android:name="com.android.alarm.permission.SET_ALARM" />
		
		<!-- Required for gcm notification to access the vibrator -->
		<uses-permission android:name="android.permission.VIBRATE" />
		
		<application>
			<activity>
				<intent-filter>
					<action android:name="android.intent.action.MAIN" />
					<category android:name="android.intent.category.LAUNCHER" />
				</intent-filter>
				<intent-filter>
					<action android:name="android.intent.action.VIEW" />
					<category android:name="android.intent.category.BROWSABLE" />
					<category android:name="android.intent.category.DEFAULT" />
					<data android:scheme="air.com.doitflash.gcm" />
				</intent-filter>
			</activity>
		
			<!-- Register the required listeners to receive gcm when app is closed -->
			<receiver android:name="com.doitflash.gcm.handler.GcmBroadcastReceiver" android:permission="com.google.android.c2dm.permission.SEND" >
				<intent-filter>
					<action android:name="com.google.android.c2dm.intent.RECEIVE" />
					<category android:name="air.com.doitflash.gcm" />
				</intent-filter>
			</receiver>
			<service android:name="com.doitflash.gcm.handler.GcmMessageHandler" />
			<receiver android:name="com.doitflash.gcm.alarm.alarmTypes.Alarm_Notification" />
			
			<!-- if gcm tasks are set for future, you need this to make sure timers are all set even after user restarts their device -->
			<receiver android:name="com.doitflash.gcm.alarm.RebootAutoStartAlarms">
				<intent-filter>
					<action android:name="android.intent.action.BOOT_COMPLETED" />
				</intent-filter>
			</receiver>
			
			<!-- Required for waking up the device when gcm notification arrives -->
			<activity android:name="com.doitflash.gcm.alarm.WakeActivity" android:theme="@style/Theme.Transparent" />
			
		</application>
</manifest>




<!--
FOR iOS:
-->
	<InfoAdditions>
		<!-- iOS 6.1 is the minimum device requirement for gcm to work -->
		<key>MinimumOSVersion</key>
		<string>6.1</string>
		
		<key>UIStatusBarStyle</key>
		<string>UIStatusBarStyleBlackOpaque</string>
		
		<key>UIRequiresPersistentWiFi</key>
		<string>NO</string>
		
		<key>UIPrerenderedIcon</key>
		<true />
		
		<key>UIDeviceFamily</key>
		<array>
			<string>1</string>
			<string>2</string>
		</array>
		
		<!-- Required for gcm ane -->
		<key>UIBackgroundModes</key>
		<array>
			<string>fetch</string>
			<string>remote-notification</string>
		</array>
		
		<!-- introduce your gcm sender id for ios here (you will introduce it again in AS3 when initializing the extension) -->
		<key>GCM_SENDER_ID</key>
		<string>000000000000</string>
		
		<key>PLIST_VERSION</key>
		<string>1</string>
		
		<!-- your iOS bundle id goes here too -->
		<key>BUNDLE_ID</key>
		<string>com.doitflash.gcm</string>
		
		<!-- Your are using gcm service, so set IS_GCM_ENABLED to true just like below -->
		<key>IS_ADS_ENABLED</key>
		<false/>
		<key>IS_ANALYTICS_ENABLED</key>
		<false/>
		<key>IS_APPINVITE_ENABLED</key>
		<false/>
		<key>IS_GCM_ENABLED</key>
		<true/>
		<key>IS_SIGNIN_ENABLED</key>
		<false/>

		
	</InfoAdditions>
		
    <requestedDisplayResolution>high</requestedDisplayResolution>
	
	<Entitlements>
	
	<!--
		You need to add all lines below just make sure to change two thing:
		1) change all "com.doitflash.gcm" to your own iOS bundle ID
		2) everywhere you see "M8DXV5X5LV" you need to enter your own provision ID instead. (HOW TO? go to your apple dev console where you are downloading your provisions from and click on edit a provision... there you will see a similar String. honestly, I don't have a clue what that is myself neither :D It's just apple's rules!
	-->
		
		<key>keychain-access-groups</key>
		<array>
			<string>M8DXV5X5LV.*</string>		
		</array>
		<key>get-task-allow</key>
		<true/>
		<key>application-identifier</key>
		<string>M8DXV5X5LV.com.doitflash.gcm</string>
		<key>com.apple.developer.team-identifier</key>
		<string>M8DXV5X5LV</string>
		<key>aps-environment</key>
		<string>development</string>
	</Entitlements>
	
	
	
	
<!--
Embedding the ANE:
-->
  <extensions>
	<!-- And finally, you need to introduce the extensions here. you will need commonDependenciesV3.0.ane or higher -->
    <extensionID>com.doitflash.air.extensions.dependency</extensionID>
    <extensionID>com.myflashlab.air.extensions.gcm</extensionID>
  </extensions>
-->
```

# Requirements
* This ANE is dependent on **androidSupport.ane** and **googlePlayServices.ane** You need to add these ANEs to your project too. [Download them from here:](https://github.com/myflashlab/common-dependencies-ANE)
* Android 10 or higher
* iOS 6.1 or higher

# Commercial Version
http://www.myflashlabs.com/product/gcm-ane-adobe-air-native-extension/

![GCM ANE](http://www.myflashlabs.com/wp-content/uploads/2015/11/product_adobe-air-ane-extension-gcm-595x738.jpg)

# Tech Details
we have tried to make the AS3 API identical for both Android and iOS but there are still some differences which you should know about when implementing this extension in your project. I will explain these differences here. 

- The first difference is with how you can obtain the senderId and server API key from Google. we have written a complete step by step tutorial on how you can get those information check here http://www.myflashlabs.com/product/gcm-ane-adobe-air-native-extension/. once you have your senderID and server API key, implementing them in your project is identical. 

- The second difference is with the gcm message that your server will send to google servers. in simple words, you need to orgenize the gcm message in a json format and send the string to google gcm servers. check here http://myflashlabs.com/showcase/AIR_EXTENSIONS/GCM/demoV4/ and choose the device type from the dropdown menu. you will see a different json string for Android and iOS. I strongly recommand you to study the json strings and see what options are available to you if you are going to send gcm to an Android device or an iOS device. On the iOS side, we are limited with apple rules. I'm sorry to tell you that you can't imagine too much when working with GCM on iOS. To learn more about what parameters are supported on the iOS side, study the "notification-payload-support" section on this page http://developers.google.com/cloud-messaging/http-server-ref#notification-payload-support. But on the Android side, you can do almost ANYTHING! 

    - Let me put it this way, **GCM on iOS:** is just a way for you to notify your users that something new is available for them so they can open your app and see what it is. But **GCM on Android:** is a way for you to remotly call on your app and do whatever you like with it! for example, maybe you need to update your app database with some very important information and you want to do this without engaging the user! you can simply send a gcm message to your app and trigger the function you like! Considering that GCM is so flexable on the Android side, we have customized the GCM payload Json message to what you can see here http://myflashlabs.com/showcase/AIR_EXTENSIONS/GCM/demoV4/. This format will allow us to add new tasks easily. these tasks must happen in native Java and not in flash. so, we have notification only at the moment but if you need background processes on the Android side, you can always contact us and put your order. Our Java dev team is ready to hear your requirements and we'll be happy to help you make them happen as fast as possible. 

- The third and the most difference between GCM in Android and iOS is with how much control you have over your gcm message. I explained a little about these controles above but let's take the notification as an example. On the Android side, you can fully control how your notification should appear. you can customize the notification icon, sound, content and many more details. we made sure we are supporting all the methods that native Android supports. small details like the notification LED color! While implementing all the latest notification features in the latest Android OS versions, we also made sure that everything will work fine on older Android versions begining from Android 2.3.6 

    - When sending a GCM on Android, you can specify an execution time. we are calling these gcm messages on Android as Tasks. so if you are on Android, you can always check which tasks are still in queue so maybe you wish to cancel their execution... you can also manually cancel a notification on Android. **on iOS side, gcm notifications will be cleaned automatically when you enter the application**.
	
- The last different between gcm extension for Android and iOS is with badges. on the iOS side, you can specify a badge number coming with your gcm message and as soon as the gcm message is delivered to your device, this badge number can be updated (you can update the badge manually from AS3 too). we don't have a similar thing on the Android side unfortunaitly. 

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  
[How to obtain gcm senderID + server API key for Android?](http://www.myflashlabs.com/adobe-air-gcm-tutorial-senderid-server-api-key-android/)  
[How to obtain gcm senderID + server API key for iOS?](http://www.myflashlabs.com/adobe-air-gcm-tutorial-senderid-server-api-key-ios/)  
[How to setup the Air xml manifest ready to work with gcm extension?](http://www.myflashlabs.com/adobe-air-gcm-tutorial-manifest-setup/)  


# Changelog
*Feb 09, 2016 - V4.9.3*
* added the missing Gcm.isSandbox property.


*Jan 20, 2016 - V4.9.2*
* bypassing xCode 7.2 bug causing iOS conflict when compiling with AirSDK 20 without waiting on Adobe or Apple to fix the problem. This is a must have upgrade for your app to make sure you can compile multiple ANEs in your project with AirSDK 20 or greater. https://forums.adobe.com/thread/2055508 https://forums.adobe.com/message/8294948


*Dec 20, 2015 - V4.9.1*
* minor bug fixes


*Nov 03, 2015 - V4.9*
* doitflash devs merged into MyFLashLab Team


*Sep 13, 2015 - V4.0*
* Built everything from the ground with the latest tools and libraries, supporting iOS+Android


*Jan 18, 2014 - V2.2*
* supports UTF-8 messages from server now also
* supports "SimpleLink" gcm type also


*Jul 11, 2013 - V2.1*
* When packaging in captive mode, local db was not created by java which is now fixed and works fine. tested on Air SDK 3.6 and should be ok with 3.7 or 3.8 also


*Jun 24, 2013 - V2.0*
* GCM message includes the following params: id, count, title, msg, info, type, imageUrl
* there are 3 types of reactions, decided on the server, when a GCM message arrives: SimpleNotification (default) - BitmapNotification - SimpleDialog
* when clicking on the notification, gcm data will be send to the invoke handeler of the app
* minor bugs fixed


*Jan 29, 2013 - V1.0*
* beginning of the journey!