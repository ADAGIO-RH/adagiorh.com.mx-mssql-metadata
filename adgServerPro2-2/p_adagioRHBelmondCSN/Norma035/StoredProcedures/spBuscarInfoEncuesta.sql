USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtener Encuestas
** Autor			: Denzel Ovando
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2020-06-17
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/


CREATE proc [Norma035].[spBuscarInfoEncuesta]
(@IDEncuesta INT, @IDEmpleado INT)
as
BEGIN
select [Norma035].[tblEncuestas].IDEncuesta  , [Norma035].[tblCatTiposEncuestas].Descripcion as "titulo_encuesta" ,
	[Norma035].[tblCatSeccion].Descripción  titulo_seccion , 
	[Norma035].[tblCatPreguntas].IDPregunta , [Norma035].[tblCatPreguntas].Pregunta , [Norma035].[tblCatPreguntas].RespuestaMaxima,
	 [Norma035].[tblCatPreguntas].Puntos,
	ISNULL([Norma035].[tblRespuestasEmpleados].Respuesta,0) as Respuesta,
	ISNULL( Norma035.tblEncuestaEmpleado.IDEncuestaEmpleado,0) as IDEncuestaEmpleado,
	isnull(Norma035.tblEncuestaEmpleado.Estatus,0) as Estatus,
	[Norma035].[tblEncuestas].IDTipoEncuesta	,
	[Norma035].tblEncuestaEmpleado.Resultado,
	[Norma035].tblEncuestaEmpleado.NivelRiesgo
	from  [Norma035].[tblEncuestas]
	inner join  [Norma035].[tblCatTiposEncuestas] on [Norma035].[tblCatTiposEncuestas].IDTipoEncuesta=[Norma035].[tblEncuestas].IDTipoEncuesta
	inner join [Norma035].[tblCatSeccion] on [Norma035].[tblCatSeccion].IDTipoEncuesta=[Norma035].[tblEncuestas].IDTipoEncuesta
	inner join  [Norma035].[tblCatPreguntas]  on [Norma035].[tblCatPreguntas].IDSeccion =[Norma035].[tblCatSeccion].IDSeccion
	left join  Norma035.tblEncuestaEmpleado on 
	Norma035.tblEncuestaEmpleado .IDEncuesta= [Norma035].[tblEncuestas].IDEncuesta and 
	(Norma035.tblEncuestaEmpleado.IDEmpleado is null or Norma035.tblEncuestaEmpleado.IDEmpleado=@IDEmpleado) 
	left join  [Norma035].[tblRespuestasEmpleados] on 
	[Norma035].[tblRespuestasEmpleados].IDPregunta = [Norma035].[tblCatPreguntas].IDPregunta and ([Norma035].[tblRespuestasEmpleados].IDEncuestaEmpleado is null or [Norma035].[tblRespuestasEmpleados].IDEncuestaEmpleado=	ISNULL( Norma035.tblEncuestaEmpleado.IDEncuestaEmpleado,0) )  

	where [Norma035].[tblEncuestas].IDEncuesta =@IDEncuesta;
	
end
GO
