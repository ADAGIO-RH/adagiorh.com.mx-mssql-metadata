USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 Reportes.spReporteBasicoAsistenciaRangoDeFechaImpreso 
		@FechaIni	= '2019-08-01'
		,@FechaFin	= '2019-08-15'
		,@Clientes	= '1' 
		,@IDUsuario = 1 

*/
		  
CREATE proc [Reportes].[spReporteBasicoHorasTranajadasRangoDeFechaImpreso] (
	@FechaIni date 
	,@FechaFin date
	,@Clientes varchar(max)			= ''    
	,@IDTipoNomina varchar(max)		= ''    
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@Prestaciones varchar(max)		= ''
	,@IDUsuario int
) as

	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	--declare 
	--	@FechaIni date =  '2019-08-01'
	--	,@FechaFin date = '2019-08-15'
	--	,@IDUsuario int = 1
	--;

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@Fechas [App].[dtFechasfull]   
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		,@Titulo Varchar(max)  
        
	;

	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@IDTipoNomina,',')),0)

	insert @dtFiltros(Catalogo,Value)    
	values
		('Clientes',@Clientes)    
		,('Divisiones',@Divisiones)    
		,('CentrosCostos',@CentrosCostos)    
		,('Departamentos',@Departamentos)    
		,('Areas',@Areas)    
		,('Sucursales',@Sucursales)    
		,('Prestaciones',@Prestaciones)    

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
    if object_id('tempdb..#tempHorasTrabajadas') is not null drop table #tempHorasTrabajadas; 
	SET DATEFIRST 7;  
  
	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u  
		Inner join App.tblPreferencias p  
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish' ;  
	end  
    
	SET LANGUAGE @IdiomaSQL; 

	    
SET @Titulo =  UPPER( 'LISTA DE HORAS TRABAJADAS DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))



	insert @Fechas  
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin  

	--select *
	--from @Fechas

	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		@FechaIni = @FechaIni           
		,@FechaFin = @FechaFin    
		,@IDTipoNomina = @IDTipoNominaInt         
		,@IDUsuario = @IDUsuario                
		,@dtFiltros = @dtFiltros 

	select c.*
    ,ROW_NUMBER()OVER(PARTITION by c.fechaOrigen,c.IDEmpleado,c.IDTipoChecada order by c.fecha) as rnchec
    ,DENSE_RANK()OVER(order by c.IDEmpleado) as rnemp
    ,DENSE_RANK()OVER(PARTITION by c.IDEmpleado order by c.fechaOrigen) as rnDias
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
		join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado 
        where c.IDTipoChecada not in ('SH') 




CREATE TABLE #tempHorasTrabajadas(
IDEmpleado int,
FechaOrigen date,
HorasTrabajadas varchar(20),
MinutosTrabajadas varchar(20)
)




DECLARE @CounterEmp INT = (SELECT MAX(rnemp)FROM #tempChecadas),
        @i INT = 1

    WHILE (@i <= @CounterEmp)
    BEGIN

        DECLARE 
                @CounterDias INT =(SELECT MAX(rnDias)FROM #tempChecadas WHERE rnemp = @i ),
                @j INT = 1
                
                

        WHILE (@j <= @CounterDias)
        BEGIN
            DECLARE
             @CounterChec INT =(SELECT MAX(rnchec)FROM #tempChecadas WHERE rnemp = @i  and rnDias = @j)
            ,@k int = 1
            ,@HorasTrabajado INT = 0
            ,@MinutosTrabajado INT = 0
            ,@idempleado int = (SELECT top 1 IDEmpleado FROM #tempChecadas WHERE rnemp = @i and rndias = @j )
            ,@fechaOrigen date = (SELECT top 1 FechaOrigen FROM #tempChecadas WHERE rnemp = @i and rndias = @j )

           

                        WHILE(@k <= @CounterChec)
                        BEGIN
                        DECLARE @entrada DATETIME,
                                @salida DATETIME
                        IF((SELECT COUNT(*)  FROM #tempChecadas
                                    WHERE rnemp = @i AND rndias = @j AND rnchec = @k )>1)
                                    BEGIN
                                     

                        SELECT @entrada = Fecha
                            FROM #tempChecadas
                                WHERE rnemp = @i AND rndias = @j AND rnchec = @k AND IDTipoChecada = 'ET'

                        SELECT @salida = Fecha
                            FROM #tempChecadas
                                WHERE rnemp = @i AND rndias = @j AND rnchec = @k AND IDTipoChecada = 'ST'

                                SET @HorasTrabajado = @HorasTrabajado + DATEDIFF(minute, @entrada, @salida)  
                                    
                                    END
                                  

                        SET @k = @k + 1
                        END
    set @MinutosTrabajado = @HorasTrabajado % 60
    set @HorasTrabajado = @HorasTrabajado / 60
    
    insert into #tempHorasTrabajadas values (@idempleado,@fechaOrigen,@HorasTrabajado,@MinutosTrabajado)
    set @HorasTrabajado = 0
    set @MinutosTrabajado = 0
        SET @j = @j + 1
        END
    

    SET @i = @i + 1
END


	

	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
        join Asistencia.tblCatIncidencias ci on ci.IDIncidencia = ie.IDIncidencia
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 
        where ci.EsAusentismo = 1

	--select * from @Fechas
	SELECT 
       empfecha.IDEmpleado,
       empFecha.ClaveEmpleado,
       empFecha.NOMBRECOMPLETO AS Nombre,
       empFecha.Puesto,
       empFecha.Fecha,
       empFecha.Area,
       empFecha.Departamento,
       empFecha.Cliente,
       empFecha.Sucursal,
       FechaStr = App.fnAddString(2, cast(empFecha.Dia AS VARCHAR(2)), '0', 1) + ' - '
                  + UPPER(SUBSTRING(empFecha.NombreMes, 1, 3)) + ' ' + UPPER(empFecha.NombreDia),
       CASE
           WHEN i.IDIncidencia IS NULL THEN
               ISNULL(
               (
                   SELECT TOP 1
                          cast(cast(Fecha AS TIME) AS VARCHAR(5))
                   FROM #tempChecadas
                   WHERE IDTipoChecada IN ( 'ET' )
                         AND FechaOrigen = empFecha.Fecha
                         AND IDEmpleado = empFecha.IDEmpleado
                   ORDER BY Fecha ASC
               ),
               'NC'
                     )
           ELSE
               i.IDIncidencia
       END Entrada,
       CASE
           WHEN i.IDIncidencia IS NULL THEN
               ISNULL(
               (
                   SELECT TOP 1
                          cast(cast(Fecha AS TIME) AS VARCHAR(5))
                   FROM #tempChecadas
                   WHERE IDTipoChecada IN ( 'ST' )
                         AND FechaOrigen = empFecha.Fecha
                         AND IDEmpleado = empFecha.IDEmpleado
                   ORDER BY Fecha DESC
               ),
               'NC'
                     )
           ELSE
               i.IDIncidencia
       END Salida,
       
                                                    
       CASE
           WHEN i.IDIncidencia IS NULL THEN
          
               CONCAT(
                         CAST(ISNULL( (Select 
                         HorasTrabajadas 
                         from #tempHorasTrabajadas 
                         where FechaOrigen = empFecha.Fecha 
                         and IDEmpleado = empFecha.IDEmpleado )  
                                    ,
                                        0
                                    ) AS VARCHAR(5)),
                         ':',
                         CAST(ISNULL( (Select 
                         MinutosTrabajadas 
                         from #tempHorasTrabajadas 
                         where FechaOrigen = empFecha.Fecha 
                         and IDEmpleado = empFecha.IDEmpleado )  
                                    ,
                                        0
                                    ) AS VARCHAR(5))
                     )
           ELSE
               i.IDIncidencia
       END HorasTrabajadas,
       i.Comentario,
       NombrePuesto = empFecha.NOMBRECOMPLETO + ' <br/> ' + COALESCE(empFecha.Puesto, ''),
       Titulo = @Titulo
FROM
(SELECT * FROM @Fechas, @dtEmpleados) AS empFecha
    LEFT JOIN #tempAusentismosIncidencias i
        ON i.IDEmpleado = empFecha.IDEmpleado
           AND i.Fecha = empFecha.Fecha
ORDER BY empFecha.IDEmpleado,
         empFecha.Fecha
GO
