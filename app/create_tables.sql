create table users (username varchar(100) not null primary key, password varchar(100), full_name varchar(200), admin boolean DEFAULT false);

insert into users values ('fred', 'foo', 'Fred Flintstone', false);
insert into users values ('barney', 'blah', 'Barney Rubble', false);
insert into users values ('wilma', 'bedrock', 'Wilma Flintstone', false);
insert into users values ('Zac', 'newpass', 'Zachary Long', true);
insert into users values ('Dongji', 'cpsc4973', 'Dongji IsCool', true);
