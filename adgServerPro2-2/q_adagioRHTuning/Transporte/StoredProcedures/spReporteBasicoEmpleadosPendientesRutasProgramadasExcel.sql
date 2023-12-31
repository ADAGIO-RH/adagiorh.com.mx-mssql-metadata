USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Transporte].[spReporteBasicoEmpleadosPendientesRutasProgramadasExcel](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int

)
AS
BEGIN
    /*
        declare @p2 Nomina.dtFiltrosRH
        insert into @p2 values(N'Empleados',N'240')
        insert into @p2 values(N'FechaIni',N'2021-11-25')
        insert into @p2 values(N'FechaFin',N'2021-11-25')
        insert into @p2 values(N'IDUsuario',N'1')
    */
	declare	
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null   
	;
	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u with (nolock)
		Inner join App.tblPreferencias p  with (nolock) 
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp with (nolock)  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp with (nolock)  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish';  
	end  
    
	SET LANGUAGE @IdiomaSQL; 
	SET DATEFIRST 7;  
	SET DATEFORMAT ymd;
    Declare 
	
	@FechaIni varchar(max) = null,
	@FechaFin varchar(max)= null;
	     
	SET @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
    SET @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))

    if object_id('tempdb..#tempRutasProgramadasExcel') is not null drop table #tempRutasProgramadasExcel;
    create table #tempRutasProgramadasExcel(
        ClaveEmpleado varchar(max),
        NombreCompleto varchar(max),
        Fecha date ,
        Fecha_t Varchar(40),
        rutas VARCHAR(max)
    );

    declare  @Fechas [App].[dtFechas]   
    insert @Fechas  
    exec app.spListaFechas @FechaIni =@FechaIni, @FechaFin =  @FechaFin
    insert into #tempRutasProgramadasExcel
    SELECT DISTINCT m.ClaveEmpleado,m.NOMBRECOMPLETO,a.Fecha ,upper(Format(a.Fecha, 'dddd dd  MMM')) 
    ,ISNULL((
        select DISTINCT concat(isnull(r1.ClaveRuta,'') , IIF(r1.ClaveRuta is null,'','/')  , isnull(r2.ClaveRuta,'')) as r from  
        Transporte.tblRutasPersonal ttp        
        left join Transporte.tblCatRutas r1 on r1.IDRuta=ttp.IDRuta1
        left join Transporte.tblCatRutas r2 on r2.IDRuta=ttp.IDRuta2
        where ttp.IDEmpleado=m.IDEmpleado  and ttp.FechaFin='9999-12-31' ),'')
    from RH.tblEmpleadosMaster m                
        cross join @Fechas a
    order by ClaveEmpleado,a.Fecha
--select * From #tempRutasProgramadasExcel
--order by ClaveEmpleado,Fecha

DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +  QUOTENAME(c.Fecha_t) +'AS '+ QUOTENAME(c.Fecha_t)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.Fecha_t,c.Fecha
				ORDER BY c.Fecha
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');
--    SELECT @cols

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Fecha_t)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.Fecha_t,c.Fecha
				ORDER BY c.Fecha
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');


	set @query1 = 'SELECT ClaveEmpleado [Clave Empleado],NombreCompleto [Nombre Completo], ' + @cols + ' from 
				(
					select 
						ClaveEmpleado
						, NombreCompleto
						, Fecha_t
						, rutas
						 
					from #tempRutasProgramadasExcel
			   ) x'

	set @query2 = '
				pivot 
				(
					 max(rutas)
					for Fecha_t in (' + @colsAlone + ')
				) p 
				order by ClaveEmpleado
				'	
	exec( @query1 + @query2) 

 
END
GO
