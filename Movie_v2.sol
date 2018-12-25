pragma solidity ^0.4.21;

contract Movie {
    address public publisher;   //电影院
    //string name;              //电影名称
    //uint price;                   //票价
    //uint public seat_num;     //坐位数量
    //bool play = false;            //电影是否已经开播

    struct Film{
      uint id;
      string name;
      uint price;
      uint seat_num;
      bool play;
    }
    uint cur_id;
    string cur_movie;
    uint cur_price;
    uint cur_seat_num;
    bool cur_play;
    
    Film [] films;
    
    mapping (address => uint) public audience;
    mapping (address => uint) public audience_balance;
    mapping (uint => address) public indexToAddress;
    mapping (uint => Film) public films_2;
  
     //合约构造方法
    function Movie () public{
        publisher = msg.sender;
        audience_balance[publisher] = 1000;
     }
     
     function add_movie(uint _id, string _name, uint _price, uint _seat_num) public {
         films_2[_id] = Film({
             id:_id,
             name:_name,
             price:_price,
             seat_num:_seat_num,
             play:false
         });
         cur_id = _id;
         cur_movie = _name;
         cur_price = _price;
         cur_seat_num = _seat_num;
         cur_play = false;
     }
  
     //更改坐位数量
    function changeSeat(uint _id, uint _seat_num) public {
        if (msg.sender != publisher) { return; }
        for(uint i = 0; i < films.length; i++){
            if(films[i].id == _id){
                if (films[i].play == true){ return; }
                films[i].seat_num = _seat_num;
            }
        }
        
        if(films_2[_id].play == true){ return; }
        films_2[_id].seat_num = _seat_num;
     }
    
      //买票方法，参数买票者，票数，买票后扣除用户以太币。
     function buyTicket(address _audience, uint _id, uint _ticket) public payable returns (bool success) {
        if (_ticket >= films_2[_id].seat_num) { 
            return false; 
        }
        if (films_2[_id].play == true){ 
            return false; 
        }
                
        uint total = films_2[_id].price * _ticket;  //计算票价
        if (audience_balance[_audience] >= total) { 
            audience_balance[_audience] -= total;
            audience_balance[publisher] += total;
            
            // _audience.transfer(_audience.balance - total);
            // publisher.transfer(publisher.balance + total);
            audience[_audience] = _ticket;
            films_2[_id].seat_num -= _ticket;
            return true;
        }
        return false;
     }

    //退票，开播后不允许买票和退票。
     function refundTicket(address _audience, uint _id, uint _ticket) public payable returns (bool success){
        //if (msg.sender != publisher) { return false; }
        if (films_2[_id].play == true){
            return false; 
        }
                
        uint total = films_2[_id].price * _ticket;
                
        if (audience[_audience] <= _ticket) { 
            if (audience_balance[publisher] >= total) { 
                audience_balance[_audience] += total;
                audience_balance[publisher] -= total;
                
                // _audience.transfer(_audience.balance + total);
                // publisher.transfer(publisher.balance - total);
                audience[_audience] -= _ticket;
                films_2[_id].seat_num += _ticket;
                return true;
            }
        }
        return false;
     }
  
     //获取电影名称
     function getName(uint _id) public view returns (string){
        return films_2[_id].name;
     }
  
    //获取剩余坐位数量
    function getSeat(uint _id) public view returns (uint){
      return films_2[_id].seat_num;
    }
  
    //播放电影，锁定
    function playMovie(uint _id) public {
        films_2[_id].play = true;
      //play = true;
    }
    
    function returnAdd() public constant returns (uint, string, uint, uint){
        //return (films_2[cur_id].id, films_2[cur_id].name, films_2[cur_id].price, films_2[cur_id].seat_num);
        return(cur_id, cur_movie, cur_price, cur_seat_num);
    }
    
    function charge(address addr, uint money)public{
        audience_balance[addr] += money;
    }
  
    // //销毁合约
    function destroy() public{ 
        if (msg.sender == publisher) { 
            selfdestruct(publisher); 
        }
    }
}