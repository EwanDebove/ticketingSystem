pragma solidity >=0.4.21 <0.6.0;

contract ticketingSystem {



	struct Artist{
		uint id;
		bytes32 name;
		uint artistCategory;
		address payable owner;
		uint totalTicketSold;
	}

	mapping  (uint => Artist) public artistsRegister;
	uint nextArtistID;

	struct Venue{
		uint id;
		bytes32 name;
		uint standardComission;
		uint capacity;
		address payable owner;
	}

	mapping (uint => Venue) public venuesRegister;
	uint nextVenueID;

	struct Concert{
		uint id;
		uint artistId;
		uint venueId;
		uint concertDate;
		uint concertPrice;
		bool validatedByArtist;
		bool validatedByVenue;
		uint totalSoldTicket;
		uint totalMoneyCollected;
	}
	mapping (uint => Concert) public concertsRegister;
	uint nextConcertID;

	struct Ticket{
		uint id;
		uint concertId;
		address payable owner;
		bool isAvailable;
		uint salePrice;
		uint amountPaid;
		bool isAvailableForSale;
	}

	mapping (uint => Ticket) public ticketsRegister;
	uint nextTicketID;

	constructor () public {
		nextArtistID = 1;
		nextVenueID = 1;
		nextConcertID = 1;
		nextTicketID = 1;
	}

	function createArtist(bytes32 _name, uint _artistCategory) public {

		artistsRegister[nextArtistID].id = nextArtistID;
		artistsRegister[nextArtistID].name = _name;
		artistsRegister[nextArtistID].artistCategory = _artistCategory;
		artistsRegister[nextArtistID].owner = msg.sender;

		nextArtistID ++;
	}


	function modifyArtist(uint _artistID, bytes32 _newName, uint _newArtistCategory, address payable _newOwner) public {
		require(artistsRegister[_artistID].owner == msg.sender);

		artistsRegister[_artistID].name = _newName;
		artistsRegister[_artistID].artistCategory = _newArtistCategory;
		artistsRegister[_artistID].owner = _newOwner;

	}

	function createVenue(bytes32 _name, uint _capacity, uint _comission)  public {
		venuesRegister[nextVenueID].id = nextVenueID;
		venuesRegister[nextVenueID].name = _name;
		venuesRegister[nextVenueID].standardComission = _comission;
		venuesRegister[nextVenueID].capacity = _capacity;
		venuesRegister[nextVenueID].owner = msg.sender;

		nextVenueID ++;
	}

	function modifyVenue(uint _id, bytes32 _newName, uint _newCapacity, uint _newComission, address payable _newOwner) public {
		require(venuesRegister[_id].owner == msg.sender);

		venuesRegister[_id].id = nextVenueID;
		venuesRegister[_id].name = _newName;
		venuesRegister[_id].capacity = _newCapacity;
		venuesRegister[_id].standardComission = _newComission;
		venuesRegister[_id].owner = _newOwner;
	}

	function createConcert(uint _artistID, uint _venueID, uint _concertDate, uint _concertPrice) public {
		concertsRegister[nextConcertID].id = nextConcertID;
		concertsRegister[nextConcertID].artistId = _artistID;
		concertsRegister[nextConcertID].venueId = _venueID;
		concertsRegister[nextConcertID].concertDate = _concertDate;
		concertsRegister[nextConcertID].concertPrice = _concertPrice;
		concertsRegister[nextConcertID].totalSoldTicket = 0;
		concertsRegister[nextConcertID].totalMoneyCollected = 0;
		if(msg.sender == artistsRegister[_artistID].owner){
			concertsRegister[nextConcertID].validatedByArtist = true;
		}
		if(msg.sender == venuesRegister[_venueID].owner){
			concertsRegister[nextConcertID].validatedByVenue = true;
		}

		nextConcertID ++;
	}
	function validateConcert(uint _concertID) public {

		if(msg.sender == artistsRegister[concertsRegister[_concertID].artistId].owner){
			concertsRegister[_concertID].validatedByArtist = true;
		}
		if(msg.sender == venuesRegister[concertsRegister[_concertID].venueId].owner){
			concertsRegister[_concertID].validatedByVenue = true;
		}
	}

function createTicket(uint _concertId, address payable _toAddress, bool isBought) private {
		
		ticketsRegister[nextTicketID].id = nextTicketID;
		ticketsRegister[nextTicketID].concertId = _concertId;
		ticketsRegister[nextTicketID].owner = _toAddress;
		ticketsRegister[nextTicketID].isAvailable = true;
		ticketsRegister[nextTicketID].isAvailableForSale = false;

		if(isBought == true){
			ticketsRegister[nextTicketID].amountPaid = concertsRegister[_concertId].concertPrice;
			concertsRegister[_concertId].totalMoneyCollected += concertsRegister[_concertId].concertPrice;
		}
		else{
			ticketsRegister[nextTicketID].amountPaid = 0;
		}
		concertsRegister[_concertId].totalSoldTicket ++;
		nextTicketID ++;
}





	function emitTicket(uint _concertId, address payable _toAddress) public {
		require(msg.sender == artistsRegister[concertsRegister[_concertId].artistId].owner);	

		createTicket(_concertId, _toAddress, false);
	}



	function buyTicket(uint _concertId) payable public {
		require(msg.value == concertsRegister[_concertId].concertPrice);
	
		createTicket(_concertId, msg.sender, true);		
	}

	function useTicket(uint	_ticketId) public {
		require(msg.sender == ticketsRegister[_ticketId].owner);
		require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate > now);
		require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate <= now + 24 * 60 * 60 );
		require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue == true);
		require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByArtist == true);
		ticketsRegister[_ticketId].owner = address(0);
		ticketsRegister[_ticketId].isAvailable = false;
	}

	

	function transferTicket(uint _ticketId, address payable _toAddress) public {
		require(msg.sender == ticketsRegister[_ticketId].owner);
		ticketsRegister[_ticketId].owner = _toAddress;
	}

    function cashOutConcert(uint _concertId, address payable _cashOutAddress) public {
		require(concertsRegister[_concertId].concertDate <= now);
		require(msg.sender == artistsRegister[concertsRegister[_concertId].artistId].owner);

		uint totalTicketSale = concertsRegister[_concertId].concertPrice * 2;
        uint venueShare = totalTicketSale * venuesRegister[concertsRegister[_concertId].venueId].standardComission / 10000;
        venuesRegister[concertsRegister[_concertId].venueId].owner.transfer(venueShare);
        _cashOutAddress.transfer(totalTicketSale - venueShare);

        artistsRegister[concertsRegister[_concertId].artistId].totalTicketSold += concertsRegister[_concertId].totalSoldTicket;

    }

    function offerTicketForSale(uint _ticketId, uint _salePrice) public {
    	require(msg.sender == ticketsRegister[_ticketId].owner);
    	require(_salePrice <= ticketsRegister[_ticketId].amountPaid);
    	ticketsRegister[_ticketId].isAvailableForSale = true;
    	ticketsRegister[_ticketId].salePrice = _salePrice;
    }

    function buySecondHandTicket(uint _ticketId) payable public {
    	require(ticketsRegister[_ticketId].isAvailableForSale == true);
    	require(msg.value == ticketsRegister[_ticketId].salePrice);
    	require(ticketsRegister[_ticketId].isAvailable == true);
    	ticketsRegister[_ticketId].owner.transfer(msg.value);
    	ticketsRegister[_ticketId].owner = msg.sender;
    }
}