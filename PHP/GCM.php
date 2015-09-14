<?php
class GCM
{
	public $registration;
	public $fields;
	public $headers;
	public $url;
	
	public function start()
	{
		$ch = curl_init();
		
		curl_setopt( $ch, CURLOPT_URL, $this->url );
		
		curl_setopt( $ch, CURLOPT_POST, true );
		curl_setopt( $ch, CURLOPT_HTTPHEADER, $this->headers);
		curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
		
		curl_setopt( $ch, CURLOPT_POSTFIELDS, json_encode( $this->fields ) );
		
		$result = curl_exec($ch);
		
		curl_close($ch);
		
		echo "<p><font color='#990000'>Google reply: </font>" . $result . "</p>";
	}
	
	
}
?>