create or replace package body rsa_utils_pkg as 

gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';


--
--
function check_prime (p_num in number) return boolean is

num number; 
i number:=1; 
c number:=0;
BEGIN
  num:=p_num;
   for i in 1..num 
   loop 
      if((mod(num,i))=0) 
       then 
          c:=c+1; 
     end if; 
  end loop; 
 if(c>2) 
 then 
     return false;
 else 
    return true;
 end if;
 
end check_prime;


--
--
function find_d (p_e in number,
                p_z in number) return number is

l_d number;
l_c number;
l_h number;
begin
  l_d := 0;
  for l_d in 0..100
  loop
    --l_d := l_d + 1;
    l_c := mod((p_e * l_d),p_z);
    l_h :=l_d;
    exit when l_c = 1;
  end loop;
  
  if l_h = 100 then
    --logger.log_error('could not find d', l_scope);
    raise_application_error(-20979,'Could not calculate result. Please try different parameters.');
  end if;
  
  return l_h;
end find_d;


--
--
function find_e (p_z in number) return number is

l_e number;
l_c number;
l_h number;
begin
  
  for l_e in 2..100
  loop
    l_c := find_gcd(p_n1 => p_z,
                    p_n2 => l_e);
    l_h := l_e;
    exit when l_c = 1;
  end loop;
  
  if l_h = 100 then
    --logger.log_error('could not find d', l_scope);
    raise_application_error(-20979,'Could not calculate result. Please try different parameters.');
  end if;
  
  return l_h;
end find_e;

function find_gcd (p_n1    IN  POSITIVE,
                   p_n2    IN  POSITIVE) RETURN POSITIVE IS

l_n1    POSITIVE := p_n1;
l_n2    POSITIVE := p_n2;
BEGIN
      WHILE NOT (l_n1 = l_n2)
      LOOP
          CASE SIGN(l_n1 - l_n2)
          WHEN +1
          THEN l_n1 := l_n1 - l_n2;
          ELSE l_n2 := l_n2 - l_n1;
          END CASE;
      END LOOP;
      RETURN (l_n1);
END find_gcd;

end rsa_utils_pkg;
/