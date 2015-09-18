drop table if exists vertex_dim_accounting_category;

create table vertex_dim_accounting_category (
        accounting_category_id                      integer not null,
        accounting_category     varchar(40)
);

insert into vertex_dim_accounting_category values(0, 'none');
insert into vertex_dim_accounting_category values(1, 'self_directed');
insert into vertex_dim_accounting_category values(2, 'managed_account');
insert into vertex_dim_accounting_category values(3, 'kmf');
insert into vertex_dim_accounting_category values(4, 'daf');
