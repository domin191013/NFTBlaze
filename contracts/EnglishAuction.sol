// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract EnglishAuction is ERC721 {
    event NewAuctionCreated(uint endsAt);
    event Bid(address indexed sender,uint bidNumber ,uint amount);
    event End(address indexed winner, uint amount);
    event result(
        address indexed bidder,
        uint t_Win,
        uint t_Lost
        );
    // State Variables 
    address payable public owner;
    IERC721 public AuctionTicket;
    uint public nftId;
    uint public AuctionNo;
    uint public NoOfWinners;
    // uint public passNumber = 1; 

    // // Top Bids Yet
    uint[] topBidsYet;

    // Struct 
    struct _auction{
        uint endAt;
        bool started;
        bool ended;
        uint highestBid;
        uint lowestbid;
        uint bidders;
    }
    struct bids{
        uint[] _bids;
    }

    mapping(uint => mapping (uint => address)) public auctionWinners;
    // Mappings
    mapping(uint => _auction) public auction;
    mapping(address => mapping(uint => mapping(uint => bool))) internal _pass;
    
    mapping(address => mapping(uint => bids)) internal _noOfBidsPerPerson;
    mapping(address => mapping(uint => mapping(uint => uint))) internal _bidPerPerson;
    mapping ( uint => address[] ) AuctionNoToWinnerList;
    mapping ( address => mapping ( uint => uint[] ) ) public bidders_all_Bids;
    // mapping ( address => uint ) AuctionNoToWinnerbid;

    // modifier 
    modifier onlyOwner(){
        require(msg.sender == owner,"Only Owner can run this function");
        _;
    }

    // Start and Pause function

    bool public StartandPause;

    

    // constructor 
    constructor(
        address _AuctionTicket,
        address payable _owner
    ) ERC721("RewardNFT","RNFT") {
        AuctionTicket = IERC721(_AuctionTicket);
        owner = _owner;
        AuctionNo;
    }

    function change_AuctionTicket_address( address _AuctionTicket ) public onlyOwner {
        AuctionTicket = IERC721(_AuctionTicket);
    }

    //  Functions 

    receive() external payable {}
    fallback() external payable {}

    function createNewAuction(uint _endAt,uint _lowestbid,uint _NoOfWinners) 
    public onlyOwner returns(bool) {
        forceEnd();
        AuctionNo+=1;
        _auction storage a = auction[AuctionNo];
        (a.endAt=(_endAt+block.timestamp),
        a.started=true,
        a.highestBid=_lowestbid,
        a.bidders=0,
        a.lowestbid=_lowestbid);
        StartandPause = true;
        NoOfWinners = _NoOfWinners;
        emit NewAuctionCreated(_endAt);
        return true;
    }

    function Start(uint _endAt) public onlyOwner {
        require(StartandPause == false, "Auction is not Pause");
        StartandPause = true;
        auction[AuctionNo].endAt = _endAt+block.timestamp;
    }

    function Pause() public onlyOwner  {
        require(StartandPause == true, "Auction is not Start");
        StartandPause = false;
        auction[AuctionNo].endAt = 0;
    }

    function checkAuction(uint _auctionNumber)public view returns(uint,bool,bool,uint,uint){
        _auction storage a = auction[_auctionNumber];
        return(a.endAt,a.started,a.ended,a.highestBid,a.lowestbid);
    }

    function currentAuctionNumber() public view returns(uint){
        return AuctionNo;
    }

    // function updateNoOfWinners( uint _NoOfWinners ) public onlyOwner {
    //     NoOfWinners = _NoOfWinners;
    // }

    // complete Logic & tested 
    function bid() external payable {
        _auction storage a = auction[AuctionNo];
        require(a.started == true , "Auction is not started yet");
        require(StartandPause == true, "Auction is Pause yet");

        if (block.timestamp > a.endAt) {
            a.ended = true;
        }

        require(a.ended == false, "Auction is already Ended!");
        require(block.timestamp < a.endAt, "Auction is already Ended!");
        require(msg.value > a.lowestbid, "value must be higher then lowest");
        require(AuctionTicket.balanceOf(msg.sender) >= 1, "You must have Token");
        require(msg.value > a.highestBid,"please enter amount higher then Previous bid");

        a.lowestbid = msg.value;
        a.highestBid = msg.value;
        a.bidders = a.bidders + 1;
        bids storage b = _noOfBidsPerPerson[msg.sender][AuctionNo];
        b._bids.push(a.bidders);
        _bidPerPerson[msg.sender][AuctionNo][a.bidders] = msg.value;
        (payable (address(this))).transfer(msg.value);

        // auctionWinners[AuctionNo][a.bidders] = msg.sender;
        emit Bid(msg.sender,a.bidders,msg.value);

        // Top Bids Yet
        topBidsYet.push( msg.value );

        if ( AuctionNoToWinnerList[AuctionNo].length == NoOfWinners ) {
            remove(0);
            AuctionNoToWinnerList[AuctionNo].push(msg.sender);
        } else {
            AuctionNoToWinnerList[AuctionNo].push(msg.sender);
        }
        // AuctionNoToWinnerbid[msg.sender] = a.bidders;
        
        bidders_all_Bids[ msg.sender ][ AuctionNo ].push( a.bidders );
    }

    function remove(uint _index) internal {
        require(_index < AuctionNoToWinnerList[AuctionNo].length, "index out of bound");

        for (uint i = _index; i < AuctionNoToWinnerList[AuctionNo].length - 1; i++) {
            AuctionNoToWinnerList[AuctionNo][i] = AuctionNoToWinnerList[AuctionNo][i + 1];
        }
        AuctionNoToWinnerList[AuctionNo].pop();
    }

    function winnersOfAuction(uint _AuctionNo) public view returns(address[] memory) {

        address[] memory Winners  = new address[](auction[_AuctionNo].bidders); 
        for (uint i = 0; i < Winners.length; i++) {
            Winners[i]  = (auctionWinners[_AuctionNo][i]);
        }
        return Winners;
    }

    // complete Logic & tested
    function checkBidsPerId(address _user) public view returns(uint[] memory){
        _auction storage a = auction[AuctionNo];
        bids storage b = _noOfBidsPerPerson[_user][AuctionNo];
        uint[] memory number = new uint[](a.bidders);
        for(uint i =0; i < b._bids.length; i++ ){
            number[i] =  b._bids[i];
        }
            return (number);        
    }

    function forceEnd()public onlyOwner{

        _auction storage a = auction[AuctionNo];
        a.endAt = block.timestamp;
        a.ended = true;

        delete topBidsYet;
    }

    function getBiddersAllBids( uint _auctionNo ) public view returns( uint[] memory ) {
        return (bidders_all_Bids[msg.sender][_auctionNo]);
    }

    function getNoOfWinners() public view returns( uint ) {
        return NoOfWinners;
    }

    function ClaimsAndRefunds( uint _auctionNo ) public {
    
        _auction storage a = auction[_auctionNo];
        require(block.timestamp > a.endAt,"Time is not up yet to claim or withdraw" );
        require(a.ended = true, "Auction is not ended yet");

        uint _bids_value;
        uint _owner_value;

        uint _Lost;
        uint _Win;

        uint[] memory _bidNO = bidders_all_Bids[msg.sender][_auctionNo];
        require(_bidNO.length != 0, "You were not part of the auction");

        for (uint256 i = 0; i < _bidNO.length; i++) {

            if(_bidPerPerson[msg.sender][_auctionNo][_bidNO[i]] > 0 ){
                if(a.bidders > NoOfWinners){
                    if( _bidNO[i] <= (a.bidders-NoOfWinners) ){

                        _bids_value = _bids_value+(_bidPerPerson[msg.sender][_auctionNo][_bidNO[i]]);
                        _bidPerPerson[msg.sender][_auctionNo][_bidNO[i]] = 0;

                        _Lost++;

                    }else if( _bidNO[i] > (a.bidders-NoOfWinners) ){ 

                        _owner_value = _owner_value+(_bidPerPerson[msg.sender][_auctionNo][_bidNO[i]]);
                        mint(msg.sender);

                        _bidPerPerson[msg.sender][_auctionNo][_bidNO[i]] = 0;

                        _Win++;

                    }

                }else if( a.bidders <= NoOfWinners ){

                    _owner_value = _owner_value+(_bidPerPerson[msg.sender][_auctionNo][_bidNO[i]]);
                    mint(msg.sender);
                    
                    _bidPerPerson[msg.sender][_auctionNo][_bidNO[i]] = 0;

                    _Win++;

                }
            }
        }

        if (_bids_value > 0 || _owner_value > 0) {

            (payable(msg.sender)).transfer(_bids_value);
            (owner).transfer(_owner_value);

            emit result(msg.sender, _Win, _Lost);

        } else if (_bids_value > 0) {

            (payable(msg.sender)).transfer(_bids_value);

            emit result(msg.sender, _Win, _Lost);

        } else if (_owner_value > 0) {

            (owner).transfer(_owner_value);

            emit result(msg.sender, _Win, _Lost);

        } else {

            revert("You already Claims and Refunds your bids!");

        }

    }

    function checkTopBids( ) public view returns ( uint[] memory ) {
        return topBidsYet;
    }

    function winnerList( uint _AuctionNo ) public view returns( address[] memory ) {
        return AuctionNoToWinnerList[_AuctionNo];
    }

    uint tokenID = 0;

    mapping(address => mapping(uint => mapping(uint => mapping(bool => bool)))) internal _passminted;

    uint public mintedTokenNo = 1;


    function mint(address _sender) internal {
        _safeMint(_sender, mintedTokenNo);
        mintedTokenNo++;
    }

}
