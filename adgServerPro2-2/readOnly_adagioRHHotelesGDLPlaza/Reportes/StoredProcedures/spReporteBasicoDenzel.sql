USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select *
--from sys.schemas
--where principal_id = 1
--order by name

/*
	Procedures	- sp
	function	- fn
	tablas		- tbl
	DataTypes	- dt
	Views		- vw
	TablasTemporales	- #temp
	constraint	- pk, fk, d, u, dx


*/

--create table RH.tblNuevaTabla(
--	IDEmpleado int 
--		constraint Fk_RHTblNuevaTabla_RHTblEmpleados_IDEmpleado 
--			foreign key references RH.tblEmpleados(IDEmpleado)
--)



create proc Reportes.spReporteBasicoDenzel(
	@Departamentos varchar(max) = ''
	,@Sucursales varchar(max) = ''
	,@IDUsuario int		
) as

	declare
		@dtFiltros Nomina.dtFiltrosRH,
		@empleados RH.dtEmpleados
	;

	if (isnull(@Departamentos,'') <> '')
	begin
		insert @dtFiltros(Catalogo,[Value])
		select 'Departamentos',@Departamentos
	end;

	if (isnull(@Sucursales,'') <> '')
	begin
		insert @dtFiltros(Catalogo,[Value])
		select 'Sucursales',@Sucursales
	end;

	insert @empleados
	exec RH.spBuscarEmpleados 
			@dtFiltros = @dtFiltros
			,@IDUsuario = @IDUsuario 

	select *
	from @empleados
GO
