<?php
class FBSV11 extends CodonModule
{
	public $title = 'Flight Booking System V1.1';
	
	public function index() {
            if(isset($this->post->action))
            {
                if($this->post->action == 'findflight') {
                $this->findflight();
                }
            }
            else
            {
            $this->set('airports', OperationsData::GetAllAirports());
            $this->set('airlines', OperationsData::getAllAirlines());
            $this->set('aircrafts', FBSVData::findaircrafttypes());
            $this->set('countries', FBSVData::findcountries());
            $this->show('fbsv/airport_search.tpl');
            }
        }

        public function findflight()
	{
		$arricao = DB::escape($this->post->arricao);
                $depicao = DB::escape($this->post->depicao);
                $airline = DB::escape($this->post->airline);
                $aircraft = DB::escape($this->post->aircraft);
                
                if(!$airline)
                    {
                        $airline = '%';
                    }
                if(!$arricao)
                    {
                        $arricao = '%';
                    }
                if(!$depicao)
                    {
                        $depicao = '%';
                    }
                if($aircraft == !'')
                {
                    $aircrafts = FBSVData::findaircraft($aircraft);
                    foreach($aircrafts as $aircraft)
                    {
                        $route = FBSVData::findschedules($arricao, $depicao, $airline, $aircraft->id);
                        if(!$route){$route=array();}
                        if(!$routes){$routes=array();}
                        $routes = array_merge($routes, $route);
                    }
                }
                else
                {
                $routes = FBSVData::findschedule($arricao, $depicao, $airline);
                }

		$this->set('allroutes', $routes);
		$this->show('fbsv/schedule_results.tpl');
                
	}
	
	public function jumpseat()  
	{
	        $icao = DB::escape($_GET['depicao']);
	        $this->set('airport', OperationsData::getAirportInfo($icao));
	        $this->set('cost', DB::escape($_GET['cost']));
	        $this->show('fbsv/jumpseatconfirm.tpl');
    	}

	public function purchase()  
	{
       
               $id = DB::escape($_GET['id']);
               $cost = $_GET['cost'];
               $curmoney = Auth::$userinfo->totalpay;
               $total = ($curmoney - $cost);
               FBSVData::purchase_ticket(Auth::$userinfo->pilotid, $total);
               FBSVData::update_pilot_location($id);
               header('Location: '.url('/FBSV11'));
                           
    	}
}
