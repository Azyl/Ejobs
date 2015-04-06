--------------------------------------------------------
--  File created - Thursday-March-12-2015   
--------------------------------------------------------
DROP PACKAGE BODY "C##AZYL"."JOBAD_LOAD";
--------------------------------------------------------
--  DDL for Type JSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "C##AZYL"."JSON" as object (
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  /* Variables */
  json_data json_value_array,
  check_for_duplicate number,

  /* Constructors */
  constructor function json return self as result,
  constructor function json(str varchar2) return self as result,
  constructor function json(str in clob) return self as result,
  constructor function json(cast json_value) return self as result,
  constructor function json(l in out nocopy json_list) return self as result,

  /* Member setter methods */
  member procedure remove(pair_name varchar2),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_value, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value varchar2, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value number, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value boolean, position pls_integer default null),
  member procedure check_duplicate(self in out nocopy json, v_set boolean),
  member procedure remove_duplicates(self in out nocopy json),

  /* deprecated putter use json_value */
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json, position pls_integer default null),
  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_list, position pls_integer default null),

  /* Member getter methods */
  member function count return number,
  member function get(pair_name varchar2) return json_value,
  member function get(position pls_integer) return json_value,
  member function index_of(pair_name varchar2) return number,
  member function exist(pair_name varchar2) return boolean,

  /* Output methods */
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2,
  member procedure to_clob(self in json, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true),
  member procedure print(self in json, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null), --32512 is maximum
  member procedure htp(self in json, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null),

  member function to_json_value return json_value,
  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value,

  /* json path_put */
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_value, base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem varchar2  , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem number    , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem boolean   , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_list , base number default 1),
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json      , base number default 1),

  /* json path_remove */
  member procedure path_remove(self in out nocopy json, json_path varchar2, base number default 1),

  /* map functions */
  member function get_values return json_list,
  member function get_keys return json_list

) not final;
/
CREATE OR REPLACE EDITIONABLE TYPE BODY "C##AZYL"."JSON" as

  /* Constructors */
  constructor function json return self as result as
  begin
    self.json_data := json_value_array();
    self.check_for_duplicate := 1;
    return;
  end;

  constructor function json(str varchar2) return self as result as
  begin
    self := json_parser.parser(str);
    self.check_for_duplicate := 1;
    return;
  end;

  constructor function json(str in clob) return self as result as
  begin
    self := json_parser.parser(str);
    self.check_for_duplicate := 1;
    return;
  end;

  constructor function json(cast json_value) return self as result as
    x number;
  begin
    x := cast.object_or_array.getobject(self);
    self.check_for_duplicate := 1;
    return;
  end;

  constructor function json(l in out nocopy json_list) return self as result as
  begin
    for i in 1 .. l.list_data.count loop
      if(l.list_data(i).mapname is null or l.list_data(i).mapname like 'row%') then
      l.list_data(i).mapname := 'row'||i;
      end if;
      l.list_data(i).mapindx := i;
    end loop;

    self.json_data := l.list_data;
    self.check_for_duplicate := 1;
    return;
  end;

  /* Member setter methods */
  member procedure remove(self in out nocopy json, pair_name varchar2) as
    temp json_value;
    indx pls_integer;

    function get_member(pair_name varchar2) return json_value as
      indx pls_integer;
    begin
      indx := json_data.first;
      loop
        exit when indx is null;
        if(pair_name is null and json_data(indx).mapname is null) then return json_data(indx); end if;
        if(json_data(indx).mapname = pair_name) then return json_data(indx); end if;
        indx := json_data.next(indx);
      end loop;
      return null;
    end;
  begin
    temp := get_member(pair_name);
    if(temp is null) then return; end if;

    indx := json_data.next(temp.mapindx);
    loop
      exit when indx is null;
      json_data(indx).mapindx := indx - 1;
      json_data(indx-1) := json_data(indx);
      indx := json_data.next(indx);
    end loop;
    json_data.trim(1);
    --num_elements := num_elements - 1;
  end;

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_value, position pls_integer default null) as
    insert_value json_value := nvl(pair_value, json_value.makenull);
    indx pls_integer; x number;
    temp json_value;
    function get_member(pair_name varchar2) return json_value as
      indx pls_integer;
    begin
      indx := json_data.first;
      loop
        exit when indx is null;
        if(pair_name is null and json_data(indx).mapname is null) then return json_data(indx); end if;
        if(json_data(indx).mapname = pair_name) then return json_data(indx); end if;
        indx := json_data.next(indx);
      end loop;
      return null;
    end;
  begin
    --dbms_output.put_line('PN '||pair_name);

--    if(pair_name is null) then
--      raise_application_error(-20102, 'JSON put-method type error: name cannot be null');
--    end if;
    insert_value.mapname := pair_name;
--    self.remove(pair_name);
    if(self.check_for_duplicate = 1) then temp := get_member(pair_name); else temp := null; end if;
    if(temp is not null) then
      insert_value.mapindx := temp.mapindx;
      json_data(temp.mapindx) := insert_value;
      return;
    elsif(position is null or position > self.count) then
      --insert at the end of the list
      --dbms_output.put_line('Test');
--      indx := self.count + 1;
      json_data.extend(1);
      json_data(json_data.count) := insert_value;
--      insert_value.mapindx := json_data.count;
      json_data(json_data.count).mapindx := json_data.count;
--      dbms_output.put_line('Test2'||insert_value.mapindx);
--      dbms_output.put_line('Test2'||insert_value.mapname);
--      insert_value.print(false);
--      self.print;
    elsif(position < 2) then
      --insert at the start of the list
      indx := json_data.last;
      json_data.extend;
      loop
        exit when indx is null;
        temp := json_data(indx);
        temp.mapindx := indx+1;
        json_data(temp.mapindx) := temp;
        indx := json_data.prior(indx);
      end loop;
      json_data(1) := insert_value;
      insert_value.mapindx := 1;
    else
      --insert somewhere in the list
      indx := json_data.last;
--      dbms_output.put_line('Test '||indx);
      json_data.extend;
--      dbms_output.put_line('Test '||indx);
      loop
--        dbms_output.put_line('Test '||indx);
        temp := json_data(indx);
        temp.mapindx := indx + 1;
        json_data(temp.mapindx) := temp;
        exit when indx = position;
        indx := json_data.prior(indx);
      end loop;
      json_data(position) := insert_value;
      json_data(position).mapindx := position;
    end if;
--    num_elements := num_elements + 1;
  end;

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value varchar2, position pls_integer default null) as
  begin
    put(pair_name, json_value(pair_value), position);
  end;

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value number, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else
      put(pair_name, json_value(pair_value), position);
    end if;
  end;

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value boolean, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else
      put(pair_name, json_value(pair_value), position);
    end if;
  end;

  member procedure check_duplicate(self in out nocopy json, v_set boolean) as
  begin
    if(v_set) then
      check_for_duplicate := 1;
    else
      check_for_duplicate := 0;
    end if;
  end;

  /* deprecated putters */

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else
      put(pair_name, pair_value.to_json_value, position);
    end if;
  end;

  member procedure put(self in out nocopy json, pair_name varchar2, pair_value json_list, position pls_integer default null) as
  begin
    if(pair_value is null) then
      put(pair_name, json_value(), position);
    else
      put(pair_name, pair_value.to_json_value, position);
    end if;
  end;

  /* Member getter methods */
  member function count return number as
  begin
    return self.json_data.count;
  end;

  member function get(pair_name varchar2) return json_value as
    indx pls_integer;
  begin
    indx := json_data.first;
    loop
      exit when indx is null;
      if(pair_name is null and json_data(indx).mapname is null) then return json_data(indx); end if;
      if(json_data(indx).mapname = pair_name) then return json_data(indx); end if;
      indx := json_data.next(indx);
    end loop;
    return null;
  end;

  member function get(position pls_integer) return json_value as
  begin
    if(self.count >= position and position > 0) then
      return self.json_data(position);
    end if;
    return null; -- do not throw error, just return null
  end;

  member function index_of(pair_name varchar2) return number as
    indx pls_integer;
  begin
    indx := json_data.first;
    loop
      exit when indx is null;
      if(pair_name is null and json_data(indx).mapname is null) then return indx; end if;
      if(json_data(indx).mapname = pair_name) then return indx; end if;
      indx := json_data.next(indx);
    end loop;
    return -1;
  end;

  member function exist(pair_name varchar2) return boolean as
  begin
    return (self.get(pair_name) is not null);
  end;

  /* Output methods */
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin
    if(spaces is null) then
      return json_printer.pretty_print(self, line_length => chars_per_line);
    else
      return json_printer.pretty_print(self, spaces, line_length => chars_per_line);
    end if;
  end;

  member procedure to_clob(self in json, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin
    if(spaces is null) then
      json_printer.pretty_print(self, false, buf, line_length => chars_per_line, erase_clob => erase_clob);
    else
      json_printer.pretty_print(self, spaces, buf, line_length => chars_per_line, erase_clob => erase_clob);
    end if;
  end;

  member procedure print(self in json, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as --32512 is the real maximum in sqldeveloper
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print(self, spaces, my_clob, case when (chars_per_line>32512) then 32512 else chars_per_line end);
    json_printer.dbms_output_clob(my_clob, json_printer.newline_char, jsonp);
    dbms_lob.freetemporary(my_clob);
  end;

  member procedure htp(self in json, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print(self, spaces, my_clob, chars_per_line);
    json_printer.htp_output_clob(my_clob, jsonp);
    dbms_lob.freetemporary(my_clob);
  end;

  member function to_json_value return json_value as
  begin
    return json_value(sys.anydata.convertobject(self));
  end;

  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value as
  begin
    return json_ext.get_json_value(self, json_path, base);
  end path;

  /* json path_put */
  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_value, base number default 1) as
  begin
    json_ext.put(self, json_path, elem, base);
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem varchar2, base number default 1) as
  begin
    json_ext.put(self, json_path, elem, base);
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem number, base number default 1) as
  begin
    if(elem is null) then
      json_ext.put(self, json_path, json_value(), base);
    else
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem boolean, base number default 1) as
  begin
    if(elem is null) then
      json_ext.put(self, json_path, json_value(), base);
    else
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem json_list, base number default 1) as
  begin
    if(elem is null) then
      json_ext.put(self, json_path, json_value(), base);
    else
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;

  member procedure path_put(self in out nocopy json, json_path varchar2, elem json, base number default 1) as
  begin
    if(elem is null) then
      json_ext.put(self, json_path, json_value(), base);
    else
      json_ext.put(self, json_path, elem, base);
    end if;
  end path_put;

  member procedure path_remove(self in out nocopy json, json_path varchar2, base number default 1) as
  begin
    json_ext.remove(self, json_path, base);
  end path_remove;

  /* Thanks to Matt Nolan */
  member function get_keys return json_list as
    keys json_list;
    indx pls_integer;
  begin
    keys := json_list();
    indx := json_data.first;
    loop
      exit when indx is null;
      keys.append(json_data(indx).mapname);
      indx := json_data.next(indx);
    end loop;
    return keys;
  end;

  member function get_values return json_list as
    vals json_list := json_list();
  begin
    vals.list_data := self.json_data;
    return vals;
  end;

  member procedure remove_duplicates(self in out nocopy json) as
  begin
    json_parser.remove_duplicates(self);
  end remove_duplicates;


end;

/
--------------------------------------------------------
--  DDL for Type JSON_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "C##AZYL"."JSON_LIST" as object (
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  list_data json_value_array,
  constructor function json_list return self as result,
  constructor function json_list(str varchar2) return self as result,
  constructor function json_list(str clob) return self as result,
  constructor function json_list(cast json_value) return self as result,

  member procedure append(self in out nocopy json_list, elem json_value, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem varchar2, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem number, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem boolean, position pls_integer default null),
  member procedure append(self in out nocopy json_list, elem json_list, position pls_integer default null),

  member procedure replace(self in out nocopy json_list, position pls_integer, elem json_value),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem varchar2),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem number),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem boolean),
  member procedure replace(self in out nocopy json_list, position pls_integer, elem json_list),

  member function count return number,
  member procedure remove(self in out nocopy json_list, position pls_integer),
  member procedure remove_first(self in out nocopy json_list),
  member procedure remove_last(self in out nocopy json_list),
  member function get(position pls_integer) return json_value,
  member function head return json_value,
  member function last return json_value,
  member function tail return json_list,

  /* Output methods */
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2,
  member procedure to_clob(self in json_list, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true),
  member procedure print(self in json_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null), --32512 is maximum
  member procedure htp(self in json_list, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null),

  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value,
  /* json path_put */
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_value, base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem varchar2  , base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem number    , base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem boolean   , base number default 1),
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_list , base number default 1),

  /* json path_remove */
  member procedure path_remove(self in out nocopy json_list, json_path varchar2, base number default 1),

  member function to_json_value return json_value
  /* --backwards compatibility
  ,
  member procedure add_elem(self in out nocopy json_list, elem json_value, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem varchar2, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem number, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem boolean, position pls_integer default null),
  member procedure add_elem(self in out nocopy json_list, elem json_list, position pls_integer default null),

  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_value),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem varchar2),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem number),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem boolean),
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_list),

  member procedure remove_elem(self in out nocopy json_list, position pls_integer),
  member function get_elem(position pls_integer) return json_value,
  member function get_first return json_value,
  member function get_last return json_value
--  */

) not final;
/
CREATE OR REPLACE EDITIONABLE TYPE BODY "C##AZYL"."JSON_LIST" as

  constructor function json_list return self as result as
  begin
    self.list_data := json_value_array();
    return;
  end;

  constructor function json_list(str varchar2) return self as result as
  begin
    self := json_parser.parse_list(str);
    return;
  end;

  constructor function json_list(str clob) return self as result as
  begin
    self := json_parser.parse_list(str);
    return;
  end;

  constructor function json_list(cast json_value) return self as result as
    x number;
  begin
    x := cast.object_or_array.getobject(self);
    return;
  end;


  member procedure append(self in out nocopy json_list, elem json_value, position pls_integer default null) as
    indx pls_integer;
    insert_value json_value := NVL(elem, json_value);
  begin
    if(position is null or position > self.count) then --end of list
      indx := self.count + 1;
      self.list_data.extend(1);
      self.list_data(indx) := insert_value;
    elsif(position < 1) then --new first
      indx := self.count;
      self.list_data.extend(1);
      for x in reverse 1 .. indx loop
        self.list_data(x+1) := self.list_data(x);
      end loop;
      self.list_data(1) := insert_value;
    else
      indx := self.count;
      self.list_data.extend(1);
      for x in reverse position .. indx loop
        self.list_data(x+1) := self.list_data(x);
      end loop;
      self.list_data(position) := insert_value;
    end if;

  end;

  member procedure append(self in out nocopy json_list, elem varchar2, position pls_integer default null) as
  begin
    append(json_value(elem), position);
  end;

  member procedure append(self in out nocopy json_list, elem number, position pls_integer default null) as
  begin
    if(elem is null) then
      append(json_value(), position);
    else
      append(json_value(elem), position);
    end if;
  end;

  member procedure append(self in out nocopy json_list, elem boolean, position pls_integer default null) as
  begin
    if(elem is null) then
      append(json_value(), position);
    else
      append(json_value(elem), position);
    end if;
  end;

  member procedure append(self in out nocopy json_list, elem json_list, position pls_integer default null) as
  begin
    if(elem is null) then
      append(json_value(), position);
    else
      append(elem.to_json_value, position);
    end if;
  end;

 member procedure replace(self in out nocopy json_list, position pls_integer, elem json_value) as
    insert_value json_value := NVL(elem, json_value);
    indx number;
  begin
    if(position > self.count) then --end of list
      indx := self.count + 1;
      self.list_data.extend(1);
      self.list_data(indx) := insert_value;
    elsif(position < 1) then --maybe an error message here
      null;
    else
      self.list_data(position) := insert_value;
    end if;
  end;

  member procedure replace(self in out nocopy json_list, position pls_integer, elem varchar2) as
  begin
    replace(position, json_value(elem));
  end;

  member procedure replace(self in out nocopy json_list, position pls_integer, elem number) as
  begin
    if(elem is null) then
      replace(position, json_value());
    else
      replace(position, json_value(elem));
    end if;
  end;

  member procedure replace(self in out nocopy json_list, position pls_integer, elem boolean) as
  begin
    if(elem is null) then
      replace(position, json_value());
    else
      replace(position, json_value(elem));
    end if;
  end;

  member procedure replace(self in out nocopy json_list, position pls_integer, elem json_list) as
  begin
    if(elem is null) then
      replace(position, json_value());
    else
      replace(position, elem.to_json_value);
    end if;
  end;

  member function count return number as
  begin
    return self.list_data.count;
  end;

  member procedure remove(self in out nocopy json_list, position pls_integer) as
  begin
    if(position is null or position < 1 or position > self.count) then return; end if;
    for x in (position+1) .. self.count loop
      self.list_data(x-1) := self.list_data(x);
    end loop;
    self.list_data.trim(1);
  end;

  member procedure remove_first(self in out nocopy json_list) as
  begin
    for x in 2 .. self.count loop
      self.list_data(x-1) := self.list_data(x);
    end loop;
    if(self.count > 0) then
      self.list_data.trim(1);
    end if;
  end;

  member procedure remove_last(self in out nocopy json_list) as
  begin
    if(self.count > 0) then
      self.list_data.trim(1);
    end if;
  end;

  member function get(position pls_integer) return json_value as
  begin
    if(self.count >= position and position > 0) then
      return self.list_data(position);
    end if;
    return null; -- do not throw error, just return null
  end;

  member function head return json_value as
  begin
    if(self.count > 0) then
      return self.list_data(self.list_data.first);
    end if;
    return null; -- do not throw error, just return null
  end;

  member function last return json_value as
  begin
    if(self.count > 0) then
      return self.list_data(self.list_data.last);
    end if;
    return null; -- do not throw error, just return null
  end;

  member function tail return json_list as
    t json_list;
  begin
    if(self.count > 0) then
      t := json_list(self.list_data);
      t.remove(1);
      return t;
    else return json_list(); end if;
  end;

  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin
    if(spaces is null) then
      return json_printer.pretty_print_list(self, line_length => chars_per_line);
    else
      return json_printer.pretty_print_list(self, spaces, line_length => chars_per_line);
    end if;
  end;

  member procedure to_clob(self in json_list, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin
    if(spaces is null) then
      json_printer.pretty_print_list(self, false, buf, line_length => chars_per_line, erase_clob => erase_clob);
    else
      json_printer.pretty_print_list(self, spaces, buf, line_length => chars_per_line, erase_clob => erase_clob);
    end if;
  end;

  member procedure print(self in json_list, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as --32512 is the real maximum in sqldeveloper
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_list(self, spaces, my_clob, case when (chars_per_line>32512) then 32512 else chars_per_line end);
    json_printer.dbms_output_clob(my_clob, json_printer.newline_char, jsonp);
    dbms_lob.freetemporary(my_clob);
  end;

  member procedure htp(self in json_list, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_list(self, spaces, my_clob, chars_per_line);
    json_printer.htp_output_clob(my_clob, jsonp);
    dbms_lob.freetemporary(my_clob);
  end;

  /* json path */
  member function path(json_path varchar2, base number default 1) return json_value as
    cp json_list := self;
  begin
    return json_ext.get_json_value(json(cp), json_path, base);
  end path;


  /* json path_put */
  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_value, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base);
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;

    objlist := json(self);
    json_ext.put(objlist, json_path, elem, base);
    self := objlist.get_values;
  end path_put;

  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem varchar2, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base);
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;

    objlist := json(self);
    json_ext.put(objlist, json_path, elem, base);
    self := objlist.get_values;
  end path_put;

  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem number, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base);
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;

    objlist := json(self);

    if(elem is null) then
      json_ext.put(objlist, json_path, json_value, base);
    else
      json_ext.put(objlist, json_path, elem, base);
    end if;
    self := objlist.get_values;
  end path_put;

  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem boolean, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base);
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;

    objlist := json(self);
    if(elem is null) then
      json_ext.put(objlist, json_path, json_value, base);
    else
      json_ext.put(objlist, json_path, elem, base);
    end if;
    self := objlist.get_values;
  end path_put;

  member procedure path_put(self in out nocopy json_list, json_path varchar2, elem json_list, base number default 1) as
    objlist json;
    jp json_list := json_ext.parsePath(json_path, base);
  begin
    while(jp.head().get_number() > self.count) loop
      self.append(json_value());
    end loop;

    objlist := json(self);
    if(elem is null) then
      json_ext.put(objlist, json_path, json_value, base);
    else
      json_ext.put(objlist, json_path, elem, base);
    end if;
    self := objlist.get_values;
  end path_put;

  /* json path_remove */
  member procedure path_remove(self in out nocopy json_list, json_path varchar2, base number default 1) as
    objlist json := json(self);
  begin
    json_ext.remove(objlist, json_path, base);
    self := objlist.get_values;
  end path_remove;


  member function to_json_value return json_value as
  begin
    return json_value(sys.anydata.convertobject(self));
  end;

  /*--backwards compatibility
  member procedure add_elem(self in out nocopy json_list, elem json_value, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem varchar2, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem number, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem boolean, position pls_integer default null) as begin append(elem,position); end;
  member procedure add_elem(self in out nocopy json_list, elem json_list, position pls_integer default null) as begin append(elem,position); end;

  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_value) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem varchar2) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem number) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem boolean) as begin replace(position,elem); end;
  member procedure set_elem(self in out nocopy json_list, position pls_integer, elem json_list) as begin replace(position,elem); end;

  member procedure remove_elem(self in out nocopy json_list, position pls_integer) as begin remove(position); end;
  member function get_elem(position pls_integer) return json_value as begin return get(position); end;
  member function get_first return json_value as begin return head(); end;
  member function get_last return json_value as begin return last(); end;
--  */

end;

/
--------------------------------------------------------
--  DDL for Type JSON_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "C##AZYL"."JSON_VALUE" as object
(
  /*
  Copyright (c) 2010 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  typeval number(1), /* 1 = object, 2 = array, 3 = string, 4 = number, 5 = bool, 6 = null */
  str varchar2(32767),
  num number, /* store 1 as true, 0 as false */
  object_or_array sys.anydata, /* object or array in here */
  extended_str clob,

  /* mapping */
  mapname varchar2(4000),
  mapindx number(32),

  constructor function json_value(object_or_array sys.anydata) return self as result,
  constructor function json_value(str varchar2, esc boolean default true) return self as result,
  constructor function json_value(str clob, esc boolean default true) return self as result,
  constructor function json_value(num number) return self as result,
  constructor function json_value(b boolean) return self as result,
  constructor function json_value return self as result,
  static function makenull return json_value,

  member function get_type return varchar2,
  member function get_string(max_byte_size number default null, max_char_size number default null) return varchar2,
  member procedure get_string(self in json_value, buf in out nocopy clob),
  member function get_number return number,
  member function get_bool return boolean,
  member function get_null return varchar2,

  member function is_object return boolean,
  member function is_array return boolean,
  member function is_string return boolean,
  member function is_number return boolean,
  member function is_bool return boolean,
  member function is_null return boolean,

  /* Output methods */
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2,
  member procedure to_clob(self in json_value, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true),
  member procedure print(self in json_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null), --32512 is maximum
  member procedure htp(self in json_value, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null),

  member function value_of(self in json_value, max_byte_size number default null, max_char_size number default null) return varchar2

) not final;
/
CREATE OR REPLACE EDITIONABLE TYPE BODY "C##AZYL"."JSON_VALUE" as

  constructor function json_value(object_or_array sys.anydata) return self as result as
  begin
    case object_or_array.gettypename
      when sys_context('userenv', 'current_schema')||'.JSON_LIST' then self.typeval := 2;
      when sys_context('userenv', 'current_schema')||'.JSON' then self.typeval := 1;
      else raise_application_error(-20102, 'JSON_Value init error (JSON or JSON\_List allowed)');
    end case;
    self.object_or_array := object_or_array;
    if(self.object_or_array is null) then self.typeval := 6; end if;

    return;
  end json_value;

  constructor function json_value(str varchar2, esc boolean default true) return self as result as
  begin
    self.typeval := 3;
    if(esc) then self.num := 1; else self.num := 0; end if; --message to pretty printer
    self.str := str;
    return;
  end json_value;

  constructor function json_value(str clob, esc boolean default true) return self as result as
    amount number := 32767;
  begin
    self.typeval := 3;
    if(esc) then self.num := 1; else self.num := 0; end if; --message to pretty printer
    if(dbms_lob.getlength(str) > 32767) then
      extended_str := str;
    end if;
    -- GHS 20120615: Added IF structure to handle null clobs
    if dbms_lob.getlength(str) > 0 then
      dbms_lob.read(str, amount, 1, self.str);
    end if;
    return;
  end json_value;

  constructor function json_value(num number) return self as result as
  begin
    self.typeval := 4;
    self.num := num;
    if(self.num is null) then self.typeval := 6; end if;
    return;
  end json_value;

  constructor function json_value(b boolean) return self as result as
  begin
    self.typeval := 5;
    self.num := 0;
    if(b) then self.num := 1; end if;
    if(b is null) then self.typeval := 6; end if;
    return;
  end json_value;

  constructor function json_value return self as result as
  begin
    self.typeval := 6; /* for JSON null */
    return;
  end json_value;

  static function makenull return json_value as
  begin
    return json_value;
  end makenull;

  member function get_type return varchar2 as
  begin
    case self.typeval
    when 1 then return 'object';
    when 2 then return 'array';
    when 3 then return 'string';
    when 4 then return 'number';
    when 5 then return 'bool';
    when 6 then return 'null';
    end case;

    return 'unknown type';
  end get_type;

  member function get_string(max_byte_size number default null, max_char_size number default null) return varchar2 as
  begin
    if(self.typeval = 3) then
      if(max_byte_size is not null) then
        return substrb(self.str,1,max_byte_size);
      elsif (max_char_size is not null) then
        return substr(self.str,1,max_char_size);
      else
        return self.str;
      end if;
    end if;
    return null;
  end get_string;

  member procedure get_string(self in json_value, buf in out nocopy clob) as
  begin
    if(self.typeval = 3) then
      if(extended_str is not null) then
        dbms_lob.copy(buf, extended_str, dbms_lob.getlength(extended_str));
      else
        dbms_lob.writeappend(buf, length(self.str), self.str);
      end if;
    end if;
  end get_string;


  member function get_number return number as
  begin
    if(self.typeval = 4) then
      return self.num;
    end if;
    return null;
  end get_number;

  member function get_bool return boolean as
  begin
    if(self.typeval = 5) then
      return self.num = 1;
    end if;
    return null;
  end get_bool;

  member function get_null return varchar2 as
  begin
    if(self.typeval = 6) then
      return 'null';
    end if;
    return null;
  end get_null;

  member function is_object return boolean as begin return self.typeval = 1; end;
  member function is_array return boolean as begin return self.typeval = 2; end;
  member function is_string return boolean as begin return self.typeval = 3; end;
  member function is_number return boolean as begin return self.typeval = 4; end;
  member function is_bool return boolean as begin return self.typeval = 5; end;
  member function is_null return boolean as begin return self.typeval = 6; end;

  /* Output methods */
  member function to_char(spaces boolean default true, chars_per_line number default 0) return varchar2 as
  begin
    if(spaces is null) then
      return json_printer.pretty_print_any(self, line_length => chars_per_line);
    else
      return json_printer.pretty_print_any(self, spaces, line_length => chars_per_line);
    end if;
  end;

  member procedure to_clob(self in json_value, buf in out nocopy clob, spaces boolean default false, chars_per_line number default 0, erase_clob boolean default true) as
  begin
    if(spaces is null) then
      json_printer.pretty_print_any(self, false, buf, line_length => chars_per_line, erase_clob => erase_clob);
    else
      json_printer.pretty_print_any(self, spaces, buf, line_length => chars_per_line, erase_clob => erase_clob);
    end if;
  end;

  member procedure print(self in json_value, spaces boolean default true, chars_per_line number default 8192, jsonp varchar2 default null) as --32512 is the real maximum in sqldeveloper
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_any(self, spaces, my_clob, case when (chars_per_line>32512) then 32512 else chars_per_line end);
    json_printer.dbms_output_clob(my_clob, json_printer.newline_char, jsonp);
    dbms_lob.freetemporary(my_clob);
  end;

  member procedure htp(self in json_value, spaces boolean default false, chars_per_line number default 0, jsonp varchar2 default null) as
    my_clob clob;
  begin
    my_clob := empty_clob();
    dbms_lob.createtemporary(my_clob, true);
    json_printer.pretty_print_any(self, spaces, my_clob, chars_per_line);
    json_printer.htp_output_clob(my_clob, jsonp);
    dbms_lob.freetemporary(my_clob);
  end;

  member function value_of(self in json_value, max_byte_size number default null, max_char_size number default null) return varchar2 as
  begin
    case self.typeval
    when 1 then return 'json object';
    when 2 then return 'json array';
    when 3 then return self.get_string(max_byte_size,max_char_size);
    when 4 then return self.get_number();
    when 5 then if(self.get_bool()) then return 'true'; else return 'false'; end if;
    else return null;
    end case;
  end;

end;

/
--------------------------------------------------------
--  DDL for Sequence SQ_JOBADID
--------------------------------------------------------

   CREATE SEQUENCE  "C##AZYL"."SQ_JOBADID"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 83 CACHE 20 NOORDER  NOCYCLE  NOPARTITION ;
--------------------------------------------------------
--  DDL for Table T_ACTIVEJOBADSDEPARTMENTS
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_ACTIVEJOBADSDEPARTMENTS" 
   (	"JOBADID" NUMBER(*,0), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0), 
	"DEPARTMENTID" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_CAREERLEVEL
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_CAREERLEVEL" 
   (	"CAREERLEVELID" NUMBER(*,0), 
	"CAREERLEVELNAME" VARCHAR2(30 BYTE), 
	"CAREERLEVELNAMEALT" VARCHAR2(30 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_CITY
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_CITY" 
   (	"CITYID" NUMBER(*,0), 
	"CITYTYPE" VARCHAR2(1 BYTE), 
	"CITYNAME" VARCHAR2(35 BYTE), 
	"CITYNAMEALT" VARCHAR2(30 BYTE), 
	"PARENTCITYNAME" VARCHAR2(35 BYTE), 
	"COUNTYID" VARCHAR2(3 BYTE), 
	"COUNTRYID" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_COMPANY
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_COMPANY" 
   (	"COMPANYID" NUMBER(*,0) GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE , 
	"COMPANYNAME" VARCHAR2(50 BYTE), 
	"COMPANYDESCRIPTION" CHAR(400 BYTE), 
	"COUNTRYID" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_DEPARTMENTS
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_DEPARTMENTS" 
   (	"DEPARTMENTID" NUMBER(*,0), 
	"DEPARTMENTNAME" VARCHAR2(40 BYTE), 
	"DEPARTMENTNAMEALT" VARCHAR2(40 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_DRIVERLICENCE
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_DRIVERLICENCE" 
   (	"DRIVERLICENCEID" VARCHAR2(5 BYTE), 
	"DRIVERLICENCEDESCRIPTION" VARCHAR2(350 BYTE), 
	"DRIVERLICENCEDESCRIPTIONALT" VARCHAR2(350 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_ERRORJOBAD
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_ERRORJOBAD" 
   (	"JODID" NUMBER, 
	"JOBNAME" VARCHAR2(50 BYTE), 
	"STARTTIME" DATE, 
	"ENDTIME" DATE, 
	"DURATION" NUMBER, 
	"MESSAGE" VARCHAR2(4000 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_INDUSTRY
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_INDUSTRY" 
   (	"INDUSTRYID" NUMBER(*,0), 
	"INDUSTRYNAME" VARCHAR2(40 BYTE), 
	"INDUSTRYNAMEALT" VARCHAR2(40 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBAD
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBAD" 
   (	"JOBADID" NUMBER(*,0), 
	"JODTITLE" VARCHAR2(250 BYTE), 
	"JOBADSTARDATE" DATE, 
	"JOBADENDDATE" DATE, 
	"JOBADPOSITIONSNR" NUMBER(*,0), 
	"JOBADAPPLICANTSNR" NUMBER(*,0), 
	"JOBADDESCRIPTION" VARCHAR2(4000 BYTE), 
	"ATTRIBUTE7" CHAR(20 BYTE), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBADCAREERLEVEL
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBADCAREERLEVEL" 
   (	"CAREERLEVELID" NUMBER(*,0), 
	"JOBADID" NUMBER(*,0), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBADCITY
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBADCITY" 
   (	"JOBADID" NUMBER(*,0), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0), 
	"CITYID" NUMBER(*,0), 
	"COUNTYID" VARCHAR2(3 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBADDRIVERLICENCE
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBADDRIVERLICENCE" 
   (	"JOBADID" NUMBER(*,0), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0), 
	"DRIVERLICENCEID" VARCHAR2(5 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBADINDUSTRY
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBADINDUSTRY" 
   (	"INDUSTRYID" NUMBER(*,0), 
	"JOBADID" NUMBER(*,0), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBADJOBTYPE
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBADJOBTYPE" 
   (	"JOBADTYPEID" NUMBER(*,0), 
	"JOBADID" NUMBER(*,0), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBADLANGUAGE
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBADLANGUAGE" 
   (	"LANGUAGEID" NUMBER(*,0), 
	"JOBADID" NUMBER(*,0), 
	"COMPANYID" NUMBER(*,0), 
	"COUNTRYID" NUMBER(*,0)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_JOBTYPE
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_JOBTYPE" 
   (	"JOBADTYPEID" NUMBER(*,0), 
	"JOBADTYPENAME" VARCHAR2(30 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_LANGUAGE
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_LANGUAGE" 
   (	"LANGUAGEID" NUMBER(*,0), 
	"LANGUAGENAME" VARCHAR2(30 BYTE), 
	"LANGUAGENAMEALT" VARCHAR2(30 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;
--------------------------------------------------------
--  DDL for Table T_SCRAPPEDADS
--------------------------------------------------------

  CREATE TABLE "C##AZYL"."T_SCRAPPEDADS" 
   (	"JOBADID" NUMBER(*,0), 
	"JOBADJSON" VARCHAR2(32767 BYTE), 
	"JSONTYPEID" NUMBER(*,0), 
	"PARSED" VARCHAR2(1 BYTE), 
	"INSERTTIME" TIMESTAMP (6) DEFAULT ON NULL SYSTIMESTAMP, 
	"PARSETIME" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "AZWEB" ;

   COMMENT ON COLUMN "C##AZYL"."T_SCRAPPEDADS"."JOBADJSON" IS 'THE JSON SCRAPPED FROM THE WEBSITE';
   COMMENT ON COLUMN "C##AZYL"."T_SCRAPPEDADS"."JSONTYPEID" IS '1 -- IS EJOBS SCRAPE';
   COMMENT ON COLUMN "C##AZYL"."T_SCRAPPEDADS"."PARSED" IS 'Y -- THE JSON HAS BEEN PARSED AND THE JOBAD HAS BEEN INSERTED
N -- THE JSJON HAS NOT YEET BEEN PARSED';
   COMMENT ON COLUMN "C##AZYL"."T_SCRAPPEDADS"."INSERTTIME" IS 'JSON RECEIVE TIMESTAMP';
