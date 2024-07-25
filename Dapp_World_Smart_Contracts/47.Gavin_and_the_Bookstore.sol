// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Bookstore {

    struct Book{
        bool exist;
        string title;
        string author;
        string publication;
    }

    address immutable owner;
    uint b = 1;
    uint[] arr;
    mapping(uint => Book) books;

    constructor(){
        owner = msg.sender;
    }

    function compare(string memory str1, string memory str2) private pure returns (bool) {
        if (bytes(str1).length != bytes(str2).length) {
            return false;
        }
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    // this function can add a book and only accessible by gavin
    function addBook(string memory title, string memory author, string memory publication) public {
        if(msg.sender != owner) revert();
        books[b] = Book(true, title, author, publication);
        b+=1;
    }

    // this function makes book unavailable and only accessible by gavin
    function removeBook(uint id) public {
        if(!books[id].exist || msg.sender!= owner || id>=b || id == 0) revert();
        books[id].exist = false;
    }

    // this function modifies the book details and only accessible by gavin
    function updateDetails(
        uint id, 
        string memory title, 
        string memory author, 
        string memory publication, 
        bool available) public {
            if(msg.sender != owner || id >= b || id == 0) revert();
            books[id] = Book(available, title, author, publication);
        }

    // this function returns the ID of all books with given title
    function findBookByTitle(string memory title) public returns (uint[] memory)  {
        delete arr;
        for(uint i = 1; i< b;i++){
            if(msg.sender == owner || books[i].exist){
                if(compare(books[i].title, title)){
                    arr.push(i);
                }
            }
        }
        return arr;
    }

    // this function returns the ID of all books with given publication
    function findAllBooksOfPublication (string memory publication) public returns (uint[] memory)  {
        delete arr;
        for(uint i = 1; i< b;i++){
            if(msg.sender == owner || books[i].exist){
                if(compare(books[i].publication, publication)){
                    arr.push(i);
                }
            }
        }
        return arr;
    }

    // this function returns the ID of all books with given author
    function findAllBooksOfAuthor (string memory author) public returns (uint[] memory)  {
        delete arr; 
        for(uint i = 1; i< b;i++){
            if(msg.sender == owner || books[i].exist){
                if(compare(books[i].author, author)){
                    arr.push(i);
                }
            }
        }
        return arr;
    }

    // this function returns all the details of book with given ID
    function getDetailsById(uint id) public view returns (
        string memory title, 
        string memory author, 
        string memory publication, 
        bool available) {
            if(msg.sender!=owner && !books[id].exist) revert();
            return (books[id].title, books[id].author, books[id].publication, books[id].exist);
        }

}