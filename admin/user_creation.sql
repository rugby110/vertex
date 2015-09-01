--create user van identified by 'pwd';
--create user mike identified by 'pwd';
--create user nikkiw identified by 'pwd';
--create user vertex identified by 'pwd';
--create user verse identified by 'pwd';
--create user sam identified by 'pwd';
--create user looker identified by 'pwd';
--create user bamboo identified by 'pwd';
--create user dthomas identified by 'pwd';

grant authentication host_pass to mike;
grant authentication local_pass to mike;
grant authentication host_pass to van;
grant authentication local_pass to van;
grant authentication host_pass to nikkiw;
grant authentication local_pass to nikkiw;
grant authentication host_pass to vertex;
grant authentication local_pass to vertex;
grant authentication host_pass to verse;
grant authentication local_pass to verse;
grant authentication host_pass to sam;
grant authentication local_pass to sam;
grant authentication host_pass to looker;
grant authentication local_pass to looker;
grant authentication host_pass to bamboo;
grant authentication local_pass to bamboo;
grant authentication host_pass to dthomas;
grant authentication local_pass to dthomas;

alter user looker search_path "$user", vertex, public

