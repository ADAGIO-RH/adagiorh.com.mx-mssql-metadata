USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-18
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spReporteBasicoUsoPorSucursal](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly ,
	@IDUsuario int=null
)
AS
BEGIN
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
		@Sucursales VARCHAR (max)= null
		,@FechaIni date 
		,@FechaFin date 
	--SET @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
 --   SET @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))    
		set @FechaIni	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaIni'			)   ,'1990-01-01')
		set @FechaFin	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaFin'			)   ,'9999-12-31')
		SET @Sucursales = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),',')),null)    

    
       
    if object_id('tempdb..#tempRutasProgramadasExcel') is not null drop table #tempRutasProgramadasExcel;
    create table #tempRutasProgramadasExcel(
        Sucursal varchar(100),         
        ClaveRuta varchar(100),         
		Descripcion Varchar(100),
		Total int,
		FechaR date,
		Fecha VARCHAR(100),
        rownumer int
    );

  

    declare  @Fechas [App].[dtFechas]   
    
    insert @Fechas  
    exec app.spListaFechas @FechaIni =@FechaIni, @FechaFin =  @FechaFin
	
    insert into #tempRutasProgramadasExcel
    SELECT  
		isnull(cs.Descripcion,'-- Sin Sucursal --'),c.ClaveRuta,c.Descripcion ,count(rpp.IDRutaProgramadaPersonal),f.Fecha,
		upper(Format(f.Fecha, 'dddd dd  MMM')),		
		ROW_NUMBER()OVER(partition by c.ClaveRuta,c.Descripcion ,cs.Descripcion,f.Fecha,cs.IDSucursal  order by cs.IDSucursal) 
		
	from Transporte.tblRutasProgramadas rp    
    	inner join @Fechas f on f.Fecha=rp.Fecha
    	inner join Transporte.tblRutasProgramadasPersonal rpp on rpp.IDRutaProgramada=rp.IDRutaProgramada 
    	inner join Transporte.tblRutasPersonal trp on trp.IDRutaPersonal=rpp.IDRutaPersonal and trp.IDEmpleado <> 0
		inner join Transporte.tblCatRutas c on c.IDRuta=rp.IDRuta
    	left join rh.tblSucursalEmpleado se on se.IDEmpleado=trp.IDEmpleado
		left join rh.tblCatSucursales cs on cs.IDSucursal=se.IDSucursal
    where  (@Sucursales  is  null) or (  cs.IDSucursal in (@Sucursales) and @Sucursales is not null )
	GROUP by c.ClaveRuta,c.Descripcion ,cs.Descripcion,f.Fecha,cs.IDSucursal
	order by f.Fecha
    

	insert into #tempRutasProgramadasExcel
    SELECT  
		'Externos',c.ClaveRuta,c.Descripcion ,count(rpp.IDRutaProgramadaPersonal),f.Fecha,
		upper(Format(f.Fecha, 'dddd dd  MMM'))
		,9999	
	from Transporte.tblRutasProgramadas rp    
    	inner join @Fechas f on f.Fecha=rp.Fecha
    	inner join Transporte.tblRutasProgramadasPersonal rpp on rpp.IDRutaProgramada=rp.IDRutaProgramada 
    	inner join Transporte.tblRutasPersonal trp on trp.IDRutaPersonal=rpp.IDRutaPersonal and trp.IDEmpleado = 0
		inner join Transporte.tblCatRutas c on c.IDRuta=rp.IDRuta    	
	GROUP by c.ClaveRuta,c.Descripcion ,f.Fecha
	order by f.Fecha


    if(not exists(select top 1 1 from #tempRutasProgramadasExcel))
    BEGIN
        select 
            Sucursal,
            ClaveRuta [Clave Ruta],
            Descripcion 
         From #tempRutasProgramadasExcel
        return 
    END
    

    DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +  QUOTENAME(c.Fecha) +'AS '+ QUOTENAME(c.Fecha)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.Fecha, c.FechaR
				ORDER BY FechaR
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');
--    SELECT @cols

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Fecha)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.Fecha, c.FechaR
				ORDER BY c.FechaR
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	--select @colsAlone
	set @query1 = 'SELECT Sucursal,ClaveRuta [Clave Ruta],Descripcion, ' + @cols + ' from 
				(
					select 
						Sucursal
						, ClaveRuta
						, Descripcion
						, Fecha
						, Total
						, rownumer
						 
					from #tempRutasProgramadasExcel
			   ) x'

	set @query2 = '
				pivot 
				(
					 max(Total)
					for Fecha in (' + @colsAlone + ')
				) p 
				order by ClaveRuta,rownumer
				'	
	exec( @query1 + @query2) 

              

END
GO
