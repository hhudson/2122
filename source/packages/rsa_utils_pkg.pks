create or replace package rsa_utils_pkg as 

--
--
function check_prime (p_num in number) return boolean;


--
--
function find_d (p_e in number,
                 p_z in number) return number;


--
--
function find_e (p_z in number) return number;


--
--
function find_gcd (p_n1    IN  POSITIVE,
                   p_n2    IN  POSITIVE) RETURN POSITIVE;

end rsa_utils_pkg;
/