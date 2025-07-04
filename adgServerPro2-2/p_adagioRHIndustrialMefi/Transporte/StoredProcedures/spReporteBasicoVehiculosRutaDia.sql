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
CREATE PROCEDURE [Transporte].[spReporteBasicoVehiculosRutaDia](
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
	@FechaIni date 
    ,@FechaFin date ;

    set @FechaIni	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaIni'			)   ,'2022-01-01')
    set @FechaFin	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaFin'			)   ,'2025-12-31')   
    
     
   
    if object_id('tempdb..#tempRutasProgramadasExcel') is not null drop table #tempRutasProgramadasExcel;
    create table #tempRutasProgramadasExcel(
        IDRuta int,
        ClaveRuta varchar(100),         
		Descripcion Varchar(100),
		HoraLlegada time,
		HoraSalida time,
		Fecha_t date,
		Fecha varchar(50),
		KMRuta int,
		PersonasAbordo int,
        rownumer int,
		IDVehiculo int ,
		Capacidad int,
		IDTipoVehiculo int,
		DescripcionTipoVehiculo varchar(100),
		Total int
    );

    

    declare  @Fechas [App].[dtFechas]   
    
    insert @Fechas  
    exec app.spListaFechas @FechaIni =@FechaIni, @FechaFin =  @FechaFin
	
    insert into #tempRutasProgramadasExcel (IDRuta,Descripcion,ClaveRuta,Fecha_t,Fecha,HoraLlegada,HoraSalida,KMRuta,PersonasAbordo,rownumer)
	select p.IDRuta,c.Descripcion,c.ClaveRuta ,p.Fecha,upper(Format(p.Fecha, 'dddd dd  MMM'))		,p.HoraLlegada,p.HoraSalida,p.KMRuta, count(pp.IDRutaProgramadaPersonal),
		ROW_NUMBER()over (order by p.Fecha)
        From Transporte.tblRutasProgramadas p
            inner join Transporte.tblRutasProgramadasPersonal pp on pp.IDRutaProgramada=p.IDRutaProgramada
			INNER JOIN Transporte.tblCatRutas C ON C.IDRuta=p.IDRuta
		where p.Fecha BETWEEN @FechaIni and @FechaFin 

        group by p.IDRuta,c.Descripcion,c.ClaveRuta,p.Fecha,p.HoraLlegada,p.HoraSalida,p.KMRuta


    if not exists(select top 1 1 from #tempRutasProgramadasExcel)
    begin 
        select 
            ClaveRuta [Clave Ruta]
            , HoraSalida  [Hora Salida]			 			
            , HoraLlegada  [Hora Llegada]				                        
            , KMRuta		[KM Ruta]	
            , Capacidad  [Capacidad]
            , DescripcionTipoVehiculo [Tipo de vehículo]
        From #tempRutasProgramadasExcel
        
        return 
    end 
        
	declare  @total  int
	declare @row int
	select  @total=count(*) from #tempRutasProgramadasExcel
    
	set @row=1
	declare @tempResponse as table (
				[ID] INT IDENTITY (1, 1) NOT NULL,   
				[IDVehiculo] int,
				[Capacidad] int            
	);
    
    
	while (@row <=@total)
    BEGIN
        
		declare  @aux  int,@capacidad int,@IDVehiculoTemp int;				
		select @aux=s.PersonasAbordo from #tempRutasProgramadasExcel s where s.rownumer=@row		        
		delete from @tempResponse
		while (@aux >0)
		BEGIN
		    
			select top 1 @capacidad=CantidadPasajeros  From Transporte.tblCatVehiculos s where s.CantidadPasajeros >=  @aux AND IDVehiculo NOT IN (SELECT IDVehiculo from @tempResponse)
			order by CantidadPasajeros asc        
            			                        
			if(@capacidad is null)
			begin             
				select top 1 @capacidad=CantidadPasajeros,@IDVehiculoTemp=IDVehiculo  From Transporte.tblCatVehiculos s where  IDVehiculo NOT IN (SELECT IDVehiculo from @tempResponse)
				order by CantidadPasajeros desc        

                
			
				insert into @tempResponse  (IDVehiculo,Capacidad) 
				select  IDVehiculo,CantidadPasajeros   From Transporte.tblCatVehiculos s where   IDVehiculo =@IDVehiculoTemp
				

				insert into #tempRutasProgramadasExcel  (IDRuta,Descripcion,ClaveRuta,Fecha_t,Fecha,HoraLlegada,HoraSalida,KMRuta,PersonasAbordo,IDVehiculo,Capacidad,IDTipoVehiculo,DescripcionTipoVehiculo,rownumer,Total) 
				select top 1 s.IDRuta,s.Descripcion,s.ClaveRuta,Fecha_t,s.Fecha,s.HoraLlegada,s.HoraSalida,s.KMRuta,s.PersonasAbordo,v.IDVehiculo,v.CantidadPasajeros,v.IDTipoVehiculo,tv.Descripcion, rownumer,1
				from Transporte.tblCatVehiculos v 
				inner join #tempRutasProgramadasExcel s on s.rownumer=@row
				inner join Transporte.tblCatTipoVehiculo tv on tv.IDTipoVehiculo=v.IDTipoVehiculo
				where   v.IDVehiculo  = @IDVehiculoTemp
				order by Fecha,CantidadPasajeros desc  
			end     
            else 
                BEGIN
                    insert into @tempResponse  (IDVehiculo,Capacidad) 
	                select top 1 IDVehiculo,CantidadPasajeros  From Transporte.tblCatVehiculos s where s.CantidadPasajeros >=  @aux AND IDVehiculo NOT IN (SELECT IDVehiculo from @tempResponse)
        	        order by CantidadPasajeros asc        

			
        			insert into #tempRutasProgramadasExcel  (IDRuta,Descripcion,ClaveRuta,Fecha_t,Fecha,HoraLlegada,HoraSalida,KMRuta,PersonasAbordo,IDVehiculo,Capacidad,IDTipoVehiculo,DescripcionTipoVehiculo,rownumer,Total) 
			        select top 1 s.IDRuta,s.Descripcion,s.ClaveRuta,Fecha_t,s.Fecha,s.HoraLlegada,s.HoraSalida,s.KMRuta,s.PersonasAbordo,v.IDVehiculo,v.CantidadPasajeros,v.IDTipoVehiculo,tv.Descripcion, rownumer,1
			        from Transporte.tblCatVehiculos v 
			        inner join #tempRutasProgramadasExcel s on s.rownumer=@row
			        inner join Transporte.tblCatTipoVehiculo tv on tv.IDTipoVehiculo=v.IDTipoVehiculo
			        where v.CantidadPasajeros >=  @aux 
			        order by Fecha,CantidadPasajeros asc       
                end   
						
			set @aux =@aux-@capacidad ;						
			set @capacidad=null;
             
		end
		
		
		set @row=@row+1;
	end
	
    --SELECT * From #tempRutasProgramadasExcel

	delete  from #tempRutasProgramadasExcel where IDVehiculo is null
    
	update  #tempRutasProgramadasExcel set rownumer=0

	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +  QUOTENAME(c.Fecha) +'AS '+ QUOTENAME(c.Fecha)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.Fecha_t,c.Fecha
				ORDER BY c.Fecha_t
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');
--    SELECT @cols

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Fecha)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.Fecha_t,c.Fecha
				ORDER BY c.Fecha_t
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');



	--select @colsAlone
	set @query1 = 'SELECT  ClaveRuta [Clave Ruta]
						, HoraSalida  [Hora Salida]			 			
						, HoraLlegada  [Hora Llegada]				
                        
						, KMRuta		[KM Ruta]	
						, Capacidad  [Capacidad]
						, DescripcionTipoVehiculo [Tipo de vehículo], ' + @cols + ' from 
				(
					select 						
						 ClaveRuta
						, HoraLlegada
						, HoraSalida						
						, KMRuta
						, Fecha		                        
						, Capacidad
						, DescripcionTipoVehiculo
						, concat(PersonasAbordo , '' - '' ,Total) [Total]
						, rownumer																 
					from #tempRutasProgramadasExcel s
					
			   ) x'

	set @query2 = '
				pivot 
				(
					 max(Total)
					 for Fecha in (' + @colsAlone + ')
				) p 
                order by ClaveRuta ,HoraSalida
				
				'	
	exec( @query1 + @query2) 


              


              

END
GO
