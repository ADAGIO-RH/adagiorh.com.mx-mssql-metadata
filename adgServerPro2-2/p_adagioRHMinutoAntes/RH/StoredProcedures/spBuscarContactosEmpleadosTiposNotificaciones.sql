USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarContactosEmpleadosTiposNotificaciones]
(
	@IDContactoEmpleadoTipoNotificacion int = 0
	,@IDEmpleado int
	,@IDUsuario int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'NombreTipoNotificacion'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	   ,@IDIdioma varchar(20)
       ,@IDIdiomaEmpleado varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    select @IDIdiomaEmpleado=App.fnGetPreferencia('Idioma', s.IDUsuario, 'es-MX')
        from Seguridad.tblUsuarios s  where IDEmpleado=@IDEmpleado
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
		IDTipoNotificacion   varchar(255)   
		,NombreTipoNotificacion       varchar(255)
		,DescripcionTipoNotificacion Varchar(max)
			
		,IDTemplateNotificacion int
		,IDMedioNotificacion  varchar(50) 
		,MedioNotificacion Varchar(255)
			
		,IDContactoEmpleadoTipoNotificacion int
		,IDEmpleado int
		,IDContactoEmpleado int 
		,IDTipoContactoEmpleado int
		,TipoContactoEmpleado Varchar(255)
		,Valor Varchar(max)
        ,RowNumber int 
	);

	INSERT @tempResponse
	SELECT 
        TN.IDTipoNotificacion,
		TN.Nombre,
		tn.Descripcion,

		Template.IDTemplateNotificacion,
		Template.IDMedioNotificacion,
		--MN.Descripcion,
		JSON_VALUE(MN.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as MedioNotificacion,

		ISNULL(CETN.IDContactoEmpleadoTipoNotificacion,0) as IDContactoEmpleadoTipoNotificacion,
		isnull(@IDEmpleado,0) as IDEmpleado,
		isnull(CETN.IDContactoEmpleado,0) as IDContactoEmpleado,
		isnull(CE.IDTipoContactoEmpleado,0) as IDTipoContactoEmpleado,
		--TCC.Descripcion as TipoContactoEmpleado,
		JSON_VALUE(TCC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoContactoEmpleado,
		CE.Value as Valor,
        ROW_NUMBER()over(partition by tn.IDTipoNotificacion order by   tn.IDTipoNotificacion)
        
	FROM APP.tblTiposNotificaciones TN
		inner join App.tblTemplateNotificaciones Template on tn.IDTipoNotificacion = Template.IDTipoNotificacion
		inner join app.tblMediosNotificaciones MN on MN.IDMedioNotificacion = Template.IDMedioNotificacion
		left join RH.tblContactosEmpleadosTiposNotificaciones CETN on CETN.IDEmpleado = @IDEmpleado
			and CETN.IDTipoNotificacion = TN.IDTipoNotificacion
			and CETN.IDTemplateNotificacion = Template.IDTemplateNotificacion
		left join RH.tblContactoEmpleado CE on CE.IDEmpleado = CETN.IDEmpleado
			and CETN.IDContactoEmpleado = CE.IDContactoEmpleado
		left join RH.tblCatTipoContactoEmpleado TCC on TCC.IDTipoContacto = CE.IDTipoContactoEmpleado
	where  (@query = '""' or contains(TN.*, @query)) 
			and (CETN.IDContactoEmpleadoTipoNotificacion = ISNULL(@IDContactoEmpleadoTipoNotificacion,0) OR ISNULL(@IDContactoEmpleadoTipoNotificacion,0) = 0)
            and TN.IsSpecial=0
            --and Template.IDIdioma=@IDIdioma
	order by TN.Nombre asc	
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDTipoNotificacion) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
    where RowNumber=1
	order by 
		case when @orderByColumn = 'NombreTipoNotificacion'			and @orderDirection = 'asc'		then NombreTipoNotificacion end,			
		case when @orderByColumn = 'NombreTipoNotificacion'			and @orderDirection = 'desc'	then NombreTipoNotificacion end desc,			
		case when @orderByColumn = 'DescripcionTipoNotificacion'	and @orderDirection = 'asc'		then DescripcionTipoNotificacion end,			
		case when @orderByColumn = 'DescripcionTipoNotificacion'	and @orderDirection = 'desc'	then DescripcionTipoNotificacion end desc,					
		NombreTipoNotificacion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
