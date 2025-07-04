USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar las Checadas de los calaboradores según los filtros  para ajustarlas a los tiempos 
				  Extras autorizados u a los horarios en su caso de que no se autorizen los tiempos extra.
** Autor   : Joseph Román  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2019-06-11  
** Paremetros  :                
** DataTypes Relacionados:   
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  

***************************************************************************************************/  
CREATE PROCEDURE [Asistencia].[spBuscarChecadasEmpleadosParaCorregir] --@FechaIni = '2019-05-01 00:00:00', @FechaFin = '2019-06-30 00:00:00',  @IDUsuario = 1 
(  
    @FechaIni Date = '1900-01-01'  
   ,@FechaFin Date =  '9999-12-31'  
   ,@EmpleadoIni Varchar(20) = '0'  
   ,@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'  
   ,@dtDepartamentos Varchar(MAX) = ''  
   ,@dtSucursales Varchar(MAX) = ''  
   ,@dtPuestos Varchar(MAX) = ''  
   ,@dtClasificacionesCorporativas Varchar(MAX) = ''  
   ,@dtDivisiones Varchar(MAX) = ''    
   ,@IDUsuario int  
)  
AS  
BEGIN  
  DECLARE @dtFechas app.dtFechas,  
		  @dtEmpleados [RH].[dtEmpleados],
		  @dtFiltros [Nomina].[dtFiltrosRH]


	set @EmpleadoIni = ISNULL(@EmpleadoIni,'0')
	set @EmpleadoFin = ISNULL(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ')


	if(isnull(@dtDepartamentos,'') <> '')
	BEGIN
	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@dtDepartamentos)
	END
	if(isnull(@dtSucursales,'') <> '')
	BEGIN
	insert into @dtFiltros(Catalogo,Value)
	values('Sucursales',@dtSucursales)
	END
	if(isnull(@dtPuestos,'') <> '')
	BEGIN
	insert into @dtFiltros(Catalogo,Value)
	values('Puestos',@dtPuestos)
	END
	if(isnull(@dtDivisiones,'') <> '')
	BEGIN
	insert into @dtFiltros(Catalogo,Value)
	values('Divisiones',@dtDivisiones)
	END
	if(isnull(@dtClasificacionesCorporativas,'') <> '')
	BEGIN
	insert into @dtFiltros(Catalogo,Value)
	values('ClasificacionesCorporativas',@dtClasificacionesCorporativas)
	END


	--select * from @dtFiltros
	--select @EmpleadoIni
	--select @EmpleadoFin
	--select @FechaIni
	--select @FechaFin

 insert into @dtEmpleados    
 Exec [RH].[spBuscarEmpleadosMaster] @FechaIni = @FechaIni  
          ,@FechaFin = @FechaFin
		  ,@EmpleadoIni = @EmpleadoIni
		  ,@EmpleadoFin = @EmpleadoFin
		  ,@dtFiltros = @dtFiltros 
		  ,@IDUsuario = @IDUsuario 


  insert into @dtFechas  
  exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin  


  
  if object_id('tempdb..#tempVigenciaEmpleados') is not null      
    drop table #tempVigenciaEmpleados  
  
  
 Create Table #tempVigenciaEmpleados  
 (  
  IDEmpleado int null,  
  Fecha Date null,  
  Vigente bit null  
 ); 


   
 insert into #tempVigenciaEmpleados  
 Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  @dtEmpleados = @dtEmpleados  
 ,@Fechas = @dtFechas  
 ,@IDUsuario = 1  


 delete  #tempVigenciaEmpleados  
  where Vigente = 0  

  
  select 
		ve.Fecha
		,e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,h.Descripcion as Horario
		,h.HoraEntrada
		,h.HoraSalida
		,c.IDChecada
		,c.Fecha as FechaAjustada 
		,c.FechaOriginal as FechaOriginal 
		,c.IDTipoChecada
		,CAST(Case when c.Fecha <> c.FechaOriginal Then 1 ELSE 0 END as bit) AS Diferente
  from #tempVigenciaEmpleados VE
	inner join @dtEmpleados E
		on E.IDEmpleado = VE.IDEmpleado
	inner join Asistencia.tblChecadas c
		on c.IDEmpleado = E.IDEmpleado
		and c.FechaOrigen = VE.Fecha
		and c.IDTipoChecada in ('ET','ST')
	Inner join Asistencia.tblHorariosEmpleados HE
		on HE.Fecha = VE.Fecha
		and HE.IDEmpleado = E.IDEmpleado 
	inner join Asistencia.tblCatHorarios H
		on H.IDHorario = HE.IDHorario
	left join Asistencia.tblIncidenciaEmpleado IE
		on IE.IDEmpleado = E.IDEmpleado
			and IE.Fecha = VE.Fecha
			and IE.IDIncidencia = 'EX'
			and IE.Autorizado = 1

where (( C.IDTipoChecada = 'ET' and c.Fecha < cast(VE.Fecha as datetime) + cast(h.HoraEntrada as datetime) )
		OR( C.IDTipoChecada = 'ST' and c.Fecha > cast(VE.Fecha as datetime) + cast(h.HoraSalida as datetime)))
	
ORDER BY  VE.Fecha ASC, 	E.ClaveEmpleado ASC






END
GO
