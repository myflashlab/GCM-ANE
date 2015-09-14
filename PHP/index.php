<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<link rel="stylesheet" type="text/css" href="css/bootstrap.css" />
<link rel="stylesheet" type="text/css" href="css/bootstrap-responsive.css" />
<link rel="stylesheet" type="text/css" href="css/myCSS.css" />
<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript" src="js/bootstrap.js"></script>
<script type="text/javascript" src="js/form.js"></script>
<title>GCM Extension for Adobe Air</title>
</head>

<body>
    <div class="" id="loginModal">
           <div class="well">
                <legend>This is a sample page to let you send GCM to your mobile device if you are using <a href="http://www.myappsnippet.com/gcm-android-ios/" target="_blank">GCM V4.0</a></legend>


                    <div class="tab-pane active in" id="public">

                        <form action="." method="post">

                          <label>Your Device</label>
                          <select class="form-control" name="deviceSelector" id="deviceSelector">
                            <option value="Android">Android</option>
                            <option value="IOS">IOS</option>
                          </select>

                          <label>Your Device RegId</label>
                          <input type="text" value="" class="span10" name="registration" required="required">

                          <label>Your Server Api Key (must not be ip locked)</label>
                          <input type="text" value="" class="span10" name="ApiKey" required="required">

							<label>gcm message json <a href="http://json.parser.online.fr/" target="_blank">prettify the json here</a></label>
							<TEXTAREA id="msgJson" name="config" class="span10"  required="required">{"type":"Alarm_Notification","time":1430627076707,"values":[{"params":[true],"name":"toWakeUp"},{"params":[100],"name":"setID"},{"params":["this is the title!"],"name":"setContentTitle"},{"params":["this is the content text!"],"name":"setContentText"},{"params":[0],"name":"setContentNumber"},{"params":["content info!"],"name":"setContentInfo"},{"params":[17301545],"name":"setSmallIcon"},{"params":[0],"name":"setLargeIconRes"},{"params":["",128],"name":"setLargeIcon"},{"params":["icon01.png",128],"name":"setLargeIconSDcard"},{"params":[true],"name":"setAutoCancel"},{"params":["#00FF00",1000,1000],"name":"setLights"},{"params":[true],"name":"setOngoing"},{"params":[false],"name":"setOnlyAlertOnce"},{"params":["alarm.setTicker"],"name":"setTicker"},{"params":["This is the sub text!  "],"name":"setSubText"},{"params":["sound01.mp3"],"name":"setSound"},{"params":[true],"name":"toVibrate"},{"params":[[{"target":0,"type":0,"scheme":"(for ANDROID) Some extra information to receive in gcm so I can do some other things I need to do"},{"target":1,"icon":17301545,"label":"google","type":1,"url":"http:\/\/www.google.com\/"},{"target":1,"icon":17301545,"label":"myflashlab","type":1,"url":"http:\/\/www.myflashlab.com\/"},{"target":1,"icon":17301545,"label":"myappsnippet","type":1,"url":"http:\/\/www.myappsnippet.com\/"}]],"name":"touchAction"}]}</TEXTAREA>

							<br>
							<br>
                            <input class="btn btn-info" name="Public" value="send gcm" class="btn btn-primary" type="submit">

                        </form>

                    </div>
           </div>








    	<?php
    	   if (isset($_POST["Public"]))
    	   {
    			echo '  <article class="container">
                  <section class="form-actions pager">';

                    $registration = $_POST["registration"];
                    $apiKey = $_POST["ApiKey"];
                    $json = $_POST["config"];
                    $config = json_decode(stripslashes($json));

                    require_once 'GCM.php';
                    $gcmStart = new GCM();
					$gcmStart->headers = array("Authorization: key=" . $apiKey, "Content-Type: application/json");
                    $gcmStart->registration = array($registration);
                    $gcmStart->url = 'https://android.googleapis.com/gcm/send';

                    // https://developers.google.com/cloud-messaging/server-ref

                    if ($_POST["deviceSelector"] == 'Android')
                    {
						$gcmStart->fields = array(
													'registration_ids'  => $gcmStart->registration,
													'data' => $config,
												);
                    }
                    else
                    {
						$gcmStart->fields = array(
													'registration_ids'  => $gcmStart->registration,
													'content_available' => true,
													'priority' => "high", // "normal" and "high" On iOS, these correspond to APNs priority 5 and 10
													'delay_while_idle' => false,
													'notification' => $config,
												);
                    }
				
				$gcmStart->start();

				echo '</section>
    				</article>';
    		}
    	?>


      <script>
        $("#deviceSelector").change(function() {
          if ($('#deviceSelector').val() == "Android")
          {
            $('#msgJson').val('{"type":"Alarm_Notification","time":1430627076707,"values":[{"params":[true],"name":"toWakeUp"},{"params":[100],"name":"setID"},{"params":["this is the title!"],"name":"setContentTitle"},{"params":["this is the content text!"],"name":"setContentText"},{"params":[0],"name":"setContentNumber"},{"params":["content info!"],"name":"setContentInfo"},{"params":[17301545],"name":"setSmallIcon"},{"params":[0],"name":"setLargeIconRes"},{"params":["",128],"name":"setLargeIcon"},{"params":["icon01.png",128],"name":"setLargeIconSDcard"},{"params":[true],"name":"setAutoCancel"},{"params":["#00FF00",1000,1000],"name":"setLights"},{"params":[true],"name":"setOngoing"},{"params":[false],"name":"setOnlyAlertOnce"},{"params":["alarm.setTicker"],"name":"setTicker"},{"params":["This is the sub text!  "],"name":"setSubText"},{"params":["sound01.mp3"],"name":"setSound"},{"params":[true],"name":"toVibrate"},{"params":[[{"target":0,"type":0,"scheme":"(for ANDROID) Some extra information to receive in gcm so I can do some other things I need to do"},{"target":1,"icon":17301545,"label":"google","type":1,"url":"http:\/\/www.google.com\/"},{"target":1,"icon":17301545,"label":"myflashlab","type":1,"url":"http:\/\/www.myflashlab.com\/"},{"target":1,"icon":17301545,"label":"myappsnippet","type":1,"url":"http:\/\/www.myappsnippet.com\/"}]],"name":"touchAction"}]}');
          }
          else
          {
            $('#msgJson').val('{"title":"my title", "body":"my body", "badge":"11", "sound":"default", "info":"(for iOS) Some extra information to receive in gcm so I can do some other things I need to do"}');
          }
        });
      </script>
</body>
</html>
