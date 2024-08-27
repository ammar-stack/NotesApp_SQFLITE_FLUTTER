class Note{

   int? id;
   String? title;
   String? description;
   String? date;

   Note(this.date,this.title,[this.description]); //making description as optional

  Note.withId(this.id,this.date,this.title,[this.description]); //named constructor

  int? get _id => id;
  String get _title => title!;
  String get _description => description!;
  String get _date => date!;

  //we don`t need a setter for our DB as our id will be generated automatically

  set _title(String newTitle){
    this.title = newTitle;
  }

  set _description(String newDescription){
    this.description = newDescription;
  }

  set _date(String newDate){
    this.date = newDate;
  }
  
  //convert a note object into a map object
  Map<String , dynamic> toMap(){
    var map = <String,dynamic>{};
    map['title'] = _title;
    map['description'] = _description;
    map['date'] = _date;
    if(id != null){
      map['id'] = _id;
    }
    return map;
  }

  //Extract a note object from a map object
  Note.fromMapObject(Map<String,dynamic> map){
    this.id = map['id'];
    this.date = map['date'];
    this.title = map['title'];
    this.description = map['description'];
  }
}