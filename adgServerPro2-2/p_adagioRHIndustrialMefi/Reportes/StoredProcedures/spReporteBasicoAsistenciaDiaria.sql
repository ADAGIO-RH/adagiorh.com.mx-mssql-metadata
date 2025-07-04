USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
       
          
CREATE proc [Reportes].[spReporteBasicoAsistenciaDiaria](          
 @dtFiltros Nomina.dtFiltrosRH readonly          
 ,@IDUsuario int          
) as          


DECLARE 
	@IDCliente int,
	@IDTipoNomina int,
	@ClaveEmpleadoInicial varchar(20),
	@ClaveEmpleadoFinal varchar(20),
	@FechaIni Datetime,
	@IDTurno int,
	@empleados [RH].[dtEmpleados] 



	SET @IDCliente = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))
	SET @IDTipoNomina = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
	SET @ClaveEmpleadoInicial = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
	SET @ClaveEmpleadoFinal = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')
	SET @FechaIni = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @IDTurno = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),','))
      
	  --select @IDCliente,@IDTipoNomina,@ClaveEmpleadoInicial,@ClaveEmpleadoFinal,@FechaIni,@IDTurno


	IF OBJECT_ID('tempdb..#tempEmpleados') IS NOT NULL
    DROP TABLE #tempEmpleados


    insert into @empleados              
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@FechaIni, @Fechafin = @FechaIni, @dtFiltros = @dtFiltros,@EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal, @IDUsuario = @IDUsuario    

	select * 
		into #tempEmpleados
	from @empleados


DECLARE    
  @DinamicColumns nvarchar(max) 
  ,@DinamicColumnsISNULL nvarchar(max) 
  ,@Query varchar(max)
  ,@bitSH bit
  ,@bitET bit
  ,@bitST bit
  ,@bitEC bit
  ,@bitSC bit

SELECT @bitSH = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'SH'
SELECT @bitET = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'ET'
SELECT @bitST = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'ST'
SELECT @bitEC = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'EC'
SELECT @bitSC = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'SC'
 
 --SELECT @bitSH
 --SELECT @bitET
 --SELECT @bitST
 --SELECT @bitEC
 --SELECT @bitSC



set @query = '
				select 
				 E.ClaveEmpleado
				,E.NOMBRECOMPLETO as NombreCompleto
				,E.Empresa
				,E.Division
				,E.RegPatronal
				,E.Sucursal
				,E.CentroCosto
				,E.Departamento
				,E.Area
				,E.Puesto
				,isnull(h.Descripcion,''SIN HORARIO'') as Horario
				'+ CASE WHEN @bitSH = 1 then',(Select Top 1 Fecha from Asistencia.tblChecadas where FechaOrigen = isnull(HE.Fecha,'''+ FORMAT(@FechaIni,'yyyy-MM-dd') + ''') and IDEmpleado = E.IDEmpleado and IDTipoChecada = ''SH'') as SIN_HORARIO '
					ELSE '' END +'
				'+ CASE WHEN @bitET = 1 then',(Select Top 1 Fecha from Asistencia.tblChecadas where FechaOrigen = isnull(HE.Fecha,'''+ FORMAT(@FechaIni,'yyyy-MM-dd') + ''') and IDEmpleado = E.IDEmpleado and IDTipoChecada = ''ET'') as ENTRADA_TRABAJO '
					ELSE '' END +'
				'+ CASE WHEN @bitSC = 1 then',(Select Top 1 Fecha from Asistencia.tblChecadas where FechaOrigen = isnull(HE.Fecha,'''+ FORMAT(@FechaIni,'yyyy-MM-dd') + ''') and IDEmpleado = E.IDEmpleado and IDTipoChecada = ''SC'') as SALIDA_COMIDA '
					ELSE '' END +'
				'+ CASE WHEN @bitEC = 1 then',(Select Top 1 Fecha from Asistencia.tblChecadas where FechaOrigen = isnull(HE.Fecha,'''+ FORMAT(@FechaIni,'yyyy-MM-dd') + ''') and IDEmpleado = E.IDEmpleado and IDTipoChecada = ''EC'') as ENTRADA_COMINDA '
					ELSE '' END +'
				'+ CASE WHEN @bitST = 1 then',(Select Top 1 Fecha from Asistencia.tblChecadas where FechaOrigen = isnull(HE.Fecha,'''+ FORMAT(@FechaIni,'yyyy-MM-dd') + ''') and IDEmpleado = E.IDEmpleado and IDTipoChecada = ''ST'') as SALIDA_TRABAJO '
					ELSE '' END +'
			 from #tempEmpleados E
				left join Asistencia.tblHorariosEmpleados HE
					on HE.IDEmpleado = E.IDEmpleado
					and HE.Fecha ='''+ FORMAT(@FechaIni,'yyyy-MM-dd') + '''
				left join Asistencia.tblCatHorarios H
					on H.IDHorario = he.IDHorario
					'+ CASE WHEN @IDTurno is null then ''
						ELSE 'and H.IDTurno = '+ CAST( @IDTurno as varchar(max)) END 
		

print @query
execute(@query)
GO
