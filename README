LazyRecord
==========

Proof of concept Lazy-Loading for ActiveRecord. Inspired by the 'kickers' of Ambition.
  
  >> b = Buzz.lazy_find(:first)
  => #<ActiveRecord::Lazy::Promise computation=#<Proc:0x025d1e50@...>>
  -------------No SQL query is run until a method is called on this 'Promise' 
  >> b.to_s
  -------------Buzz Load (0.000578)   SELECT * FROM buzz LIMIT 1
  => "Inaugural Buzz"
  
Use the +lazy_record+ class method to make this the default for a certain class:
  
  class Buzz << ActiveRecord::Base
    lazy_record
  end
  
  >> b = Buzz.find(:first)
  => #<ActiveRecord::Lazy::Promise computation=#<Proc:0x025d1e50@...>>
  -------------No SQL query is run until a method is called on this 'Promise' 
  >> b.to_s
  -------------Buzz Load (0.000578)   SELECT * FROM buzz LIMIT 1
  => "Inaugural Buzz"


Why you might want to use this
===========

Say you've got some kick-ass cache_fu going on in your views - huge blocks of HTML being cached with a TTL of 30 mins or so.
But, each hit on your controller still fires off the 'spensive DB queries to fetch your tag cloud. With lazy loading, these
queries aren't run until absolutely necessary - giving your DB a rest til your cache expires, and boosting your reqs/sec.


Why you might not want to use this
===========

  >> b = Buzz.lazy_find(123023424)
  => #<ActiveRecord::Lazy::Promise computation=#<Proc:0x025d1e50@...>>
  >> puts "booleans are screwed" if b
  booleans are screwed


Promise code from here: http://moonbase.rydia.net/software/lazy.rb/

Contact
=======
Jesse Newland
jnewland@gmail.com