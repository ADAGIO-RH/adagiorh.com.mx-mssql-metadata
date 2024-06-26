USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las incidencias de los calaboradores según los filtros
** Autor			: Joseph Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2021-07-26			Joseph Roman	Corrección de bug para compararcion de '*' contra un Bit
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spBuscarIncidenciasEmpleadosAutorizacion] 
(
	@IDIncidenciaEmpleado int = 0
   ,@FechaIni Date = '1900-01-01'
   ,@FechaFin Date =  '9999-12-31'
   ,@EmpleadoIni Varchar(20) = '0'
   ,@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'
   ,@Incidencias Varchar(MAX) = '*'
   ,@Ausentismos Varchar(MAX) = '*'
   ,@Autorizaciones Varchar(MAX) = '*'
   ,@Departamentos Varchar(MAX) = '*'
   ,@Sucursales Varchar(MAX) = '*'
   ,@Puestos Varchar(MAX) = '*'
   ,@ClasificacionesCorporativas Varchar(MAX) = '*'
   ,@Divisiones Varchar(MAX) = '*'  
   ,@IDUsuario int
)
AS
BEGIN
	--DECLARE @FechaIni Date = '2017-10-07'
	--DECLARE @FechaFin Date =  '2019-10-17'
	--DECLARE @EmpleadoIni Varchar(20) = '0'
	--DECLARE @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'
	--DECLARE @Incidencias Varchar(MAX) = '*'
	--DECLARE @Autorizaciones Varchar(MAX) = '*'
	--DECLARE @Departamentos Varchar(MAX) = '*'
	--DECLARE @Sucursales Varchar(MAX) = '*'
	--DECLARE @Puestos Varchar(MAX) = '*'

	declare 
		 @IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
	from Seguridad.tblUsuarios u with (nolock)
		Inner join App.tblPreferencias p with (nolock)
			on u.IDPreferencia = p.IDPreferencia
		Inner join App.tblDetallePreferencias dp with (nolock)
			on dp.IDPreferencia = p.IDPreferencia
		Inner join App.tblCatTiposPreferencias tp with (nolock)
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario
			and tp.TipoPreferencia = 'Idioma'

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL

	select IE.IDIncidenciaEmpleado
		  ,IE.IDEmpleado
		  ,EM.ClaveEmpleado
		  ,EM.NOMBRECOMPLETO as NombreCompleto
		  ,EM.Departamento
		  ,EM.Sucursal
		  ,EM.Puesto
		  ,IE.Fecha
		  ,substring(upper(DATENAME(weekday,IE.Fecha)),1,3) as Dia
		  ,ISNULL(H.Descripcion,'SIN HORARIO')	as		Horario
		  ,ISNULL(H.HoraEntrada,'00:00:00.000') as		HoraEntrada
		  ,ISNULL(H.HoraSalida,'00:00:00.000')		as	HoraSalida
		  ,ISNULL(H.JornadaLaboral,'00:00:00.000')	as	Jornada
		  ,ISNULL(cast(IE.Entrada as Time),'00:00:00.000') as	Entrada
		  ,ISNULL(cast(IE.Salida as Time),'00:00:00.000')  as	Salida
		  ,ISNULL(cast(IE.TiempoTrabajado as Time),'00:00:00.000')  as	TiempoTrabajado
		  ,I.IDIncidencia
		  ,I.Descripcion as Incidencia
		  ,ISNULL(IE.TiempoSugerido,'00:00:00.000')		as TiempoSugerido 
		  ,ISNULL(IE.TiempoAutorizado,'00:00:00.000')	as TiempoAutorizado
		  ,ISNULL(IE.Autorizado,0)	as Autorizado
		  ,ISNULL(IE.ComentarioTextoPlano,'') as Comentario
		  ,IE.FechaHoraAutorizacion
	from Asistencia.tblIncidenciaEmpleado IE with (nolock)
		Inner join RH.tblEmpleadosMaster EM with (nolock) on IE.IDEmpleado = EM.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		Left join Asistencia.tblCatHorarios H with (nolock) on IE.IDHorario = H.IDHorario
		Left Join Asistencia.tblCatIncidencias I with (nolock) on IE.IDIncidencia = I.IDIncidencia
	WHERE ((IE.IDIncidenciaEmpleado = @IDIncidenciaEmpleado) or (@IDIncidenciaEmpleado = 0)) 
		AND (IE.Fecha BETWEEN @FechaIni and @FechaFin)
		AND (EM.ClaveEmpleado BETWEEN ISNULL(@EmpleadoIni,'0') and ISNULL(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ'))
		AND ((I.IDIncidencia in (Select ITEM FROM App.Split(@Incidencias,',')))OR(@Incidencias = '*'))
		AND ((I.IDIncidencia in (Select ITEM FROM App.Split(@Ausentismos,',')))OR(@Ausentismos = '*'))
		AND ((@Autorizaciones = '*') OR (IE.Autorizado in (Select CAST(ITEM as BIT) FROM App.Split(CASE WHEN @Autorizaciones = '*' THEN '0,1' 
																										WHEN @Autorizaciones = '1' THEN '1' 
																										WHEN @Autorizaciones = '0' THEN '0' 
																										ELSE '' END,','))))
		AND ((EM.IDDepartamento in (Select ITEM FROM App.Split(@Departamentos,',')))OR(@Departamentos = '*'))
		AND ((EM.IDSucursal in (Select ITEM FROM App.Split(@Sucursales,',')))OR(@Sucursales = '*'))
		AND ((EM.IDPuesto in (Select ITEM FROM App.Split(@Puestos,',')))OR(@Puestos = '*'))
		AND ((EM.IDClasificacionCorporativa in (Select ITEM FROM App.Split(@ClasificacionesCorporativas,',')))OR(@ClasificacionesCorporativas = '*'))
		AND ((EM.IDDivision in (Select ITEM FROM App.Split(@Divisiones,',')))OR(@Divisiones = '*'))
END

GO
