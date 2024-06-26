USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar en la [Dashboard].[tblHistorialVigenciasPorFechas] por fechas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-09
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Dashboard].[spBuscarHistorialVigenciasPorFechas](
     @FechaIni date
    ,@FechaFin date
    ,@IDUsuario int
) as
    Declare @IDPreferencia int = 0
	   ,@IDIdioma varchar(10)
	  ;

    select @IDPreferencia = isnull(IDPreferencia,0)
    from [Seguridad].[tblUsuarios]
    where IDUsuario = @IDUsuario
    
    if (@IDPreferencia > 0)
    BEGIN
        select @IDIdioma= i.[SQL]
	   from App.tblDetallePreferencias dp with (NOLOCK)
		  join App.tblIdiomas i on i.IDIdioma =  dp.Valor
	   where dp.IDPreferencia= @IDPreferencia and dp.IDTipoPreferencia = 1 /* La preferencia Idioma es el IDPreferencia 1*/
	   
	   set @IDIdioma = case when isnull(@IDIdioma,'') = '' then 'Spanish' else @IDIdioma end
	   SET Language @IDIdioma;
    end ELSE
    BEGIN
	   SET Language 'Spanish';
    END

    select 
	   Fecha
	   ,LEFT(DATENAME(WEEKDAY,Fecha),3) + ' ' +
		  CONVERT(VARCHAR(6),Fecha,106) FechaStr
	   ,Total
    from [Dashboard].[tblHistorialVigenciasPorFechas] with (nolock)
    where Fecha BETWEEN @FechaIni and @FechaFin
GO
