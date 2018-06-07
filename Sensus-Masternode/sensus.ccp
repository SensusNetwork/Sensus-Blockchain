require_once($_SERVER['DOCUMENT_ROOT'].'/private/config.php');
require_once($_SERVER['DOCUMENT_ROOT'].'/private/init/mysql.php');
require_once($_SERVER['DOCUMENT_ROOT'].'/private/class/sensus.php');
function check_mn($ip){
	global $info;
	if (in_array("$ip:9999", $info)) {
		return 'online';
	}
	return 'offline';
}
function sensusx_restart($ip){
	shell_exec("sensus-cli -datadir=/home/sensus/data/$ip stop > /dev/null 2>/dev/null &");
	sleep(10);
	shell_exec("taskset -c 0-5 csensusd -datadir=/home/sensus/data/$ip -daemon > /dev/null 2>/dev/null &");
}
function sensus_editConf($ip, $pkey){
	$path = "/home/sensus/data/$ip/sensus.conf";
	$lines = explode("\n", file_get_contents($path));
	$conf = "";
	foreach($lines as $v) {
		if(empty($v)) continue;
		$param = explode("=", $v);
		if($param[0] == 'masternodeprivkey'){
			$param[1] = $pkey;
		}
		$conf = "$conf{$param[0]}={$param[1]}\n";
	}
	file_put_contents($path, $conf);
}
if(empty($_POST['txid'])) die("empty");
if(preg_match('/[^0-9a-z]/', $_POST['txid'])) die('wrong_txid');
$tx = $_POST['txid'];
$sensus = new ($config['x_user'], $config['x_pass'], $config['x_host'], $config['x_port']);
$info = $sensus->masternode('list', 'addr');
$raw_tx = $sensus->getrawtransaction($tx);
if(empty($raw_tx)) die('wrong_txid');
$decode_tx = $sensus->decoderawtransaction($raw_tx);
if($decode_tx["vout"]['0']["value"] != 1000 && $decode_tx["vout"]['1']["value"] != 1000) die('not_100000_sensus_TX');
	
if($decode_tx["vout"]['0']["value"] == 100000){
	$outputs = $decode_tx["vout"]['0']["n"];
	$address = $decode_tx["vout"]['0']["scriptPubKey"]["addresses"]['0'];
}
	
if($decode_tx["vout"]['1']["value"] == 100000){
	$outputs = $decode_tx["vout"]['1']["n"];
	$address = $decode_tx["vout"]['1']["scriptPubKey"]["addresses"]['0'];
}
	
$balance = 0; $balance = @file_get_contents;
if($balance < 1000) die('not_100000_sensus_BALANCE');
$end_block = $sensus->getblockcount();
$start_block = $end_block - 15;
while($end_block != $start_block){ // check 15 conf
	$hash_block = $sensus->getblockhash($start_block);
	$info_block = $sensus->getblock($hash_block);
	if(in_array($tx, $info_block["tx"])){
		die("not_15_conf");
	}
	$start_block++;
}
$pkey = $sensus->masternode('genkey');
$list = array_diff(scandir('/home/sensus/data/'), array('..', '.'));
foreach($list as $val){
	$query = $db->prepare("SELECT * FROM `stat` WHERE `ip` = :ip");
	$query->bindParam(':ip', $val, PDO::PARAM_STR);
	$query->execute();
	if($query->rowCount() == 0) continue;
	$row = $query->fetch();
	$status = check_mn($val);
	if($status == 'offline' && time() > $row['last']+60*60*24*7) { // find free slot
		$ip = $val;
		sensus_editConf($ip, $pkey);
		sensus_restart($ip);
		echo "mn1 $ip:9999 $pkey $tx $outputs\n";
		die;
	}
}
echo 'full';
