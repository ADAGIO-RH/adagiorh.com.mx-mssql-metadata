USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los documentos de expedientes digital que se solicitan para reclutamiento
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/
CREATE  PROCEDURE [Intranet].[spBuscarExpedientesDigitalesEmpleado]
(
	@IDExpedienteDigitalEmpleado int = 0	
    ,@IDCarpetaExpedienteDigital int= 0
	,@IDEmpleado int = 0
    ,@IDUsuario int = 0	
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDExpedienteDigitalEmpleado'
	,@orderDirection varchar(4) = 'asc'
)



AS
BEGIN

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@ID_PERIODICIDAD_SIN_DEFINIR INT = 1
	   ,@ID_PERIODICIDAD_DIARIA INT = 2
	   ,@ID_PERIODICIDAD_SEMANAL INT = 3
	   ,@ID_PERIODICIDAD_QUINCENAL INT = 4
	   ,@ID_PERIODICIDAD_MENSUAL INT = 5
	   ,@ID_PERIODICIDAD_BIMESTRAL INT = 6
	   ,@ID_PERIODICIDAD_TRIMESTRAL INT = 7
	   ,@ID_PERIODICIDAD_SEMESTRAL INT = 8
	   	,@IDIdioma varchar(20)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', null, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDExpedienteDigitalEmpleado' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	
  
  		set @query = case 
			when @query is null then '""' 
			when @query = '' then '""'
			when @query = '""' then '""'
		else '"'+@query + '*"' end  

    declare @tbl as table(
        IDExpedienteDigitalEmpleado int ,
        IDEmpleado int ,
        Name varchar(max),
        ContentType varchar(255),
        PathFile varchaR(255),
        Size int ,
        IDExpedienteDigital int ,
        Caduca bit,
        IDPeriodicidad int ,
        FechaVencimiento datetime,
        FechaHoraActualizacion datetime,
        PeriodoVigenciaDocumento int,
        CodigoExpedientDigital varchar(255),
        DescripcionExpedientDigital varchar(max),
        Requerido BIT,
        IDCarpetaExpedienteDigital int,
        CarpetaExpedienteDigital varchar(255),		
		IntranetConfig nvarchar(MAX)
    );
    

    insert into  @tbl
    SELECT 
                  
            0 as  IDExpedienteDigitalEmpleado
            ,0 as IDEmpleado
            ,cast('' as varchar(max)) as Name
            ,'' as ContentType
            ,'' PathFile
            ,0 Size
        -- isnull([EDE].[IDExpedienteDigitalCandidato],0)
		-- 	,isnull([EDE].[IDCandidato],0 ) as IDCandidato
		-- 	,isnull([EDE].[Name] ,'') 
		-- 	,isnull([EDE].[ContentType],'') 
		-- 	,isnull([EDE].[PathFile],'') as PathFile
		-- 	,isnull([EDE].[Size],0) as Size
			,ISNULL([CED].[IDExpedienteDigital],0) as IDExpedienteDigital
			,CED.Caduca
			,ISNULL(CED.IDPeriodicidad, 0) as IDPeriodicidad
			,  CAST('9999-01-01' as datetime) as FechaVencimiento
            , ced.FechaHoraActualizacion
			,ISNULL(CED.PeriodoVigenciaDocumento,0) as PeriodoVigenciaDocumento
			,[CED].[Codigo] as CodigoExpedientDigital
			,[CED].[Descripcion] as DescripcionExpedientDigital
			,isnull([CED].[Requerido],0) as Requerido
			,ISNULL([CCED].[IDCarpetaExpedienteDigital],0) as IDCarpetaExpedienteDigital
			,[CCED].Descripcion as CarpetaExpedienteDigital					
			,ISNULL(CED.IntranetConfig, '{ Editable: false }') as IntranetConfig
    FROM RH.tblCatExpedientesDigitales CED
        inner join RH.tblCatCarpetasExpedienteDigital CCED with(nolock)  on CED.IDCarpetaExpedienteDigital = CCED.IDCarpetaExpedienteDigital        
     WHERE ced.Intranet=1  
     
    IF @IDEmpleado > 0 
    begin
        
        UPDATE  CED
        SET        
        CED.IDExpedienteDigitalEmpleado=EDE.IDExpedienteDigitalEmpleado ,
        CED.IDEmpleado=EDE.IDEmpleado ,
        CED.Name=EDE.Name ,
        CED.ContentType=EDE.ContentType ,
        CED.PathFile=EDE.PathFile ,
        CED.Size=EDE.Size ,
        CED.FechaVencimiento= case 
				when CED.Caduca = 1 and EDE.FechaVencimiento is null THEN
					case
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_DIARIA THEN dateadd(day, 1*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_SEMANAL THEN dateadd(week, 1*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_QUINCENAL then dateadd(week, 2*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_MENSUAL then dateadd(MONTH, 1*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_BIMESTRAL then dateadd(MONTH, 2*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_TRIMESTRAL then dateadd(MONTH, 3*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_SEMESTRAL then dateadd(MONTH, 5*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						else CAST('9999-01-01' as datetime)
					end
				WHEN CED.Caduca = 1 AND EDE.FechaVencimiento IS NOT NULL THEN EDE.FechaVencimiento
				else CAST('9999-01-01' as datetime)
				end
        
        
        FROM @tbl CED
        inner join  RH.tblExpedienteDigitalEmpleado EDE ON EDE.IDExpedienteDigital=CED.IDExpedienteDigital and EDE.IDEmpleado=@IDEmpleado
        
    end

    
    
     -- LEFT JOIN Reclutamiento.tblExpedienteDigitalCandidato EDE ON EDE.IDExpedienteDigital=CED.IDExpedienteDigital 
    --  and ( isnull(EDE.IDCandidato,0)=0 or EDE.IDCandidato=@IDCandidato )

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tbl
	select @TotalRegistros = COUNT([IDExpedienteDigitalEmpleado]) from @tbl		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from @tbl 
    where  ( isnull(@IDExpedienteDigitalEmpleado,0)=0 or  IDExpedienteDigitalEmpleado=@IDExpedienteDigitalEmpleado )     
	order by 
		case when @orderByColumn = 'IDExpedienteDigitalEmpleado'			and @orderDirection = 'asc'		then [IDExpedienteDigitalEmpleado] end,			
		case when @orderByColumn = 'IDExpedienteDigitalEmpleado'			and @orderDirection = 'desc'	then [IDExpedienteDigitalEmpleado] end desc,
		[IDExpedienteDigitalEmpleado] asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
