USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-07-22
-- Description:	 Buscar los avisos del momento para el empleado
/*
declare @dt [Nomina].[dtFiltrosRH]  
insert into  @dt (Catalogo,[Value])values('IDTipoAviso',1)

declare @pt [Nomina].[dtFiltrosRH]  
insert into  @pt (Catalogo,[Value])values('PageNumber',1)
insert into  @pt (Catalogo,[Value])values('PageSize',5)
insert into  @pt (Catalogo,[Value])values('TotalPages',0)
insert into  @pt (Catalogo,[Value])values('query','')
insert into  @pt (Catalogo,[Value])values('orderByColumn','Titulo')
insert into  @pt (Catalogo,[Value])values('orderDirection','asc')


exec [Comunicacion].[spBuscarAvisosForEmpleado] @IDEmpleado =1279, @IDUsuario=1 ,@dtFiltros=@dt ,@dtPagination=@pt
*/
CREATE Procedure [Comunicacion].[spBuscarAvisosForEmpleado]
( 
	@IDUsuario int 
	, @IDEmpleado int     
    ,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH]  READONLY             

)
AS
BEGIN
    declare          
		@IDIdioma varchar(225),		 
	    @orderByColumn	varchar(50) = 'Titulo',
	    @orderDirection varchar(4) = 'asc'  ,
        @IDTipoAviso int  ,
        @FechaHoy date     

    select @FechaHoy=GETDATE()
                
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');                      
    Select  @IDTipoAviso=isnull(Value,null) from @dtFiltros where Catalogo = 'IDTipoAviso'


    IF OBJECT_ID(N'tempdb..#tempSetPagination') IS NOT NULL
    BEGIN
        DROP TABLE #tempSetPagination
    END

    
    select 
    s.IDAviso,
    s.Titulo,
    s.Descripcion,    
    s.FechaInicio,
    s.FechaFin,
    s.Ubicacion,
    s.HoraInicio,
    ROW_NUMBER()Over(Order by   s.FechaCreacion desc )  as [row]
    into #tempSetPagination
    From Comunicacion.tblAvisos  s
    left join Comunicacion.tblEmpleadosAvisos  ea on ea.IDAviso=s.IDAviso
    where  s.IDEstatus=2  and ((s.IsGeneral=1 AND EA.IDAviso IS NULL)  or ( s.IsGeneral=0 and ea.IDEmpleado=@IDEmpleado)) and ( s.IDTipoAviso=@IDTipoAviso or @IDTipoAviso is null) 
    and  (( s.IDTipoAviso=1 and s.FechaInicio >=@FechaHoy )  or (s.IDTipoAviso=2 and @FechaHoy BETWEEN  s.FechaInicio and s.FechaFin))

    if exists(select top 1 * from @dtPagination)
        BEGIN
            exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
        end
    else 
        begin 
            select  * From #tempSetPagination order by row desc
        end
 

END
GO
