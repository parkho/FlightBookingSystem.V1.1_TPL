<?php
$pilotid = Auth::$userinfo->pilotid;
$last_location = FBSVData::get_pilot_location($pilotid, 1);
$last_name = OperationsData::getAirportInfo($last_location->arricao);
if(!$last_location)
{
FBSVData::update_pilot_location(Auth::$userinfo->hub);
}

?>
<script src="http://code.jquery.com/jquery-latest.js"></script>
	<script>
$(document).ready(function(){
	$("select").change(function () {
		var cost = "";
		$("select option:selected").each(function (){
			cost = $(this).attr("name");
                        airport = $(this).text();
		});
		$("input[name=cost]").val( cost );
                $("input[name=airport]").val( airport );
		}).trigger('change');
});
	</script>
<h3>Flight Dispatch</h3>
<ul>
	<li>Current Location: <b><font color="#FF3300"><?php echo $last_location->arricao?> - <?php echo $last_name->name?></font></b></li>
</ul>
<form action="<?php echo url('/FBSV11');?>" method="post" enctype="multipart/form-data">
    <table>
	    <tr>
            <td >Select An Airline:</td>
            <td colspan="2">
                <select style="width: 30%" name="airline">
                    <option value="">All</option>
                    <?php
                        foreach ($airlines as $airline)
                            {echo '<option value="'.$airline->code.'">'.$airline->name.'</option>';}
                    ?>
                </select>
            </td>
        </tr>
        <tr>
            <td >Select An Aircraft Type:</td>
            <td colspan="2">
                <select style="width: 30%" name="aircraft">
                    <option value="">All</option>
                    <?php
						$airc = FBSVData::routeaircraft($last_location->arricao);
						if(!$airc)
							{
								echo '<option>No Aircraft Available!</option>';
							}
						else
							{
								foreach ($airc as $air)
									{
									$ai = FBSVData::getaircraftbyID($air->aircraft);
					?>
							<option value="<?php echo $ai->icao ;?>"><?php
							echo $ai->name ;?></option>
					<?php
									}
							}
                    ?>
                </select> <img src="<?php echo fileurl('/lib/images/info.png') ;?>" title="Available aircraft to search from your current location">
            </td>
        </tr>
        <tr>
            <td>Select Arrival Airfield:</td>
            <td >
                <select style="width: 30%" name="arricao">
                    <option value="">All</option>
                    <?php
						$airs = FBSVData::arrivalairport($last_location->arricao);
						if(!$airs)
							{
								echo '<option>No Airports Available!</option>';
							}
						else
							{
								foreach ($airs as $air)
									{
										$nam = OperationsData::getAirportInfo($air->arricao);
										echo '<option value="'.$air->arricao.'">'.$air->arricao.' - '.$nam->name.'</option>';
									}
							}
                    ?>
                </select> <img src="<?php echo fileurl('/lib/images/info.png') ;?>" title="Available airports to search from your current location">
            </td>
        	<td align="center" >
				<input type="hidden" name="action" value="findflight" />
                <input type="submit" name="submit" value="Search Flight" />
			</td>			
		</tr>
    </table>
</form>
</div>

<h3>Pilot Transfer</h3>
<ul>
	<li>Your Bank limit is : <font color="#66FF00"><?php echo FinanceData::FormatMoney(Auth::$userinfo->totalpay) ;?></font></li>
</ul>
<br />
<form action="<?php echo url('/FBSV11/jumpseat');?>" method="get">
	<table>
		<tr>	
			<td>select airport to transfer : </td>
			<td >
					
					<select name="depicao" onchange="listSel(this,'cost')">
						<option value="">--Select--</option>
						<?php
							foreach ($airports as $airport){
								$distance = round(SchedulesData::distanceBetweenPoints($last_name->lat, $last_name->lng, $airport->lat, $airport->lng), 0);
								$permile = Config::Get('JUMPSEAT_COST');
								$cost = ($permile * $distance);
								$check = PIREPData::getLastReports(Auth::$userinfo->pilotid, 1,1);
								if($cost >= Auth::$userinfo->totalpay)
								   {
									continue;
								   }
								elseif($check->accepted == PIREP_ACCEPTED || !$check)
								   {
									 echo "<option name='{$cost}' value='{$airport->icao}'>{$airport->icao} - {$airport->name}    /Cost - <font color='#66FF00'>$ {$cost}</font></option>";
								   }
									?>
								   
								   <hr> 
					 <?php                   
							 }
						?> 
					</select>
				</td>
					 <?php
						if(Auth::$userinfo->totalpay == "0")
							{
						?>
								<td align="center"><input type="submit" name="submit" value="Transfer" disabled="disabled"></td> 
						<?php
							}
						else
							{
						?>
								<td align="center"><input type="submit" name="submit" value="Transfer" ></td>
						<?php
							}
						?>
						 
		</tr>
    </table>
<input type="hidden" name="cost">
<input type="hidden" name="airport">
</form>


	
	 
