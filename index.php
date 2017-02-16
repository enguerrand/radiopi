<?php
    include_once("./config/frontend.php");        

    if ($_GET['stop']) {
        exec("$BASE_PATH/scripts/stop.sh");
        header('Location: '.$BASE_URL);
        exit;
    }

    elseif ($_GET['start']) {
        $stn=$_GET['start']; 
        exec("$BASE_PATH/scripts/start.sh ".$stn." > /tmp/radio.log 2>&1");
        sleep (3);
        header('Location: '.$BASE_URL);
        exit;
    }

    elseif ($_GET['volume']) {
        $action=$_GET['volume']; 
        $valid_actions = array("up", "down", "tmute");
        if(in_array ($action, $valid_actions)){
            exec("$BASE_PATH/scripts/volume.sh ".$action);
        }
        #sleep (1);
        header('Location: '.$BASE_URL);
        exit;
    }


    function show_running($station){
        global $BASE_PATH;
        ?>
            <P>Currently running:</P>
            <H1><?php echo $station; ?></H1>
            <a class="stop_button" href="?stop=true">STOP</a>
            <br>
            <table>
                <tr>
                    <td><a href="?volume=down" class="vol_button">-</a></td>
                    <td><a href="?volume=tmute" class="vol_button"><?php echo shell_exec("$BASE_PATH/scripts/volume.sh get"); ?></a></td>
                    <td><a href="?volume=up" class="vol_button">+</a></td>
                </tr>
            </table>
        <?php
    }

    function show_stopped(){
        global $BASE_URL;
        global $BASE_PATH;
        ?>
           <P>Choose station:</P>
           <form action="<?php echo $BASE_URL; ?>" method="GET">
           <?php
                $stations = file($BASE_PATH."/config/stations.conf", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
                echo "<select name=\"start\" class=\"dropdown\" size=\"1\">";
                foreach ($stations as $stn_num => $station) {
                    $station_entries=explode('=',$station);   
                    $station_name=$station_entries[0];
                    echo "<option";
                    echo " value=\"".$station_name."\">";
                    echo $station_name;
                    echo "</option>\n";
                }
                echo "</select>";
           ?>
           <input type="submit" class="submit" value="Start"></form>
        <?php
    }
?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<HTML>
    <HEAD>
        <TITLE>Raspberry Pi Radio!</TITLE>
        <LINK rel="stylesheet" type="text/css" href="style.css">
    </HEAD>
    <BODY>
    <?php
        if ( file_exists($BASE_PATH."/status/CURRENT_STATION") ) {
            $station=file_get_contents($BASE_PATH."/status/CURRENT_STATION");
            show_running($station);
        }
        else {
            show_stopped();
        }
    ?>
    <p><a href="./shutdown.php" class="simple_button">Shutdown</a></p>
    </BODY>
</HTML>
