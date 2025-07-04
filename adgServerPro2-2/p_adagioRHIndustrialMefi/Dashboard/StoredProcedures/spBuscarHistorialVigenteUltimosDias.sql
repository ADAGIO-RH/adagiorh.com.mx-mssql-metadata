USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Actualiza la tabla [Dashboard].[tblHistorialVigenciasPorFechas] los últimos días 
				    que recibe por parámetro.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-09
** Paremetros		:  @Dias int = indica la cantidad de días atrás que buscará el historial
				   @IDUsuario int = indica el usuario que ejecuta el reporte.            
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Dashboard].[spBuscarHistorialVigenteUltimosDias](
    @Dias int
    ,@IDUsuario int
)as
    Declare @IDPreferencia int = 0
	   ,@IDIdioma varchar(10)
	   ,@FechaIni date = dateadd(day, (@Dias * -1), getdate())    
	   ,@FechaFin date = getdate()	;

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

    if object_id('tempdb..#tempResult') is not null
	   drop table #tempResult;


    create table #tempResult (Fecha date, FechaStr varchar(50),Total int);

    insert into #tempResult
    EXEC [Dashboard].[spBuscarHistorialVigenciasPorFechas] @FechaIni = @FechaIni
											    ,@FechaFin = @FechaFin
											    ,@IDUsuario = @IDusuario
    select
    Fecha
    ,LEFT(DATENAME(WEEKDAY,Fecha),3) + ' ' +
		  CONVERT(VARCHAR(6),Fecha,106) FechaStr
    ,Total
    from #tempResult
GO
