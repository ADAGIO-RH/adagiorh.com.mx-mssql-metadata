USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar Horarios Empleados por fechas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-08-14
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Asistencia].[spBuscarHorariosEmpleados](
     @IDEmpleado int 
    ,@FechaInicio date 
    ,@FechaFin date 
    ,@IDUsuario int
) as

    SET DATEFIRST 7;

    declare @IDIdioma Varchar(5)
	   ,@IdiomaSQL varchar(100) = null;
 
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

    SELECT he.IDHorarioEmpleado
		  ,he.IDEmpleado
		  , he.IDHorario
		  , h.Codigo as CodigoHorario
		  , h.Descripcion as Horario
		  , h.HoraEntrada
		  , h.HoraSalida
		  , he.Fecha
		  , SUBSTRING(datename(weekday, he.Fecha),1,3)  as Dia
		  , he.FechaHoraRegistro
    from [Asistencia].[tblHorariosEmpleados] he with (nolock)
	   join Asistencia.tblCatHorarios h with (nolock) on he.IDHorario = h.IDHorario
    where he.IDEmpleado = @IDEmpleado
	   and he.Fecha BETWEEN @FechaInicio and @FechaFin
    order by he.Fecha desc
GO
