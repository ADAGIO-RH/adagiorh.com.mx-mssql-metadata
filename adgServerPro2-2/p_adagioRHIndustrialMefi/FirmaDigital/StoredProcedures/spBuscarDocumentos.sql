USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca Documentos según la opción que recibe por parámetro.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-05
** Paremetros		:  
		@tipo    -1 : Todos los Documentos
				  0  : Documentos Pendientes que Requieren Mi Firma
				  1  : Documentos Firmados que ya Firme.
				  2  : Documentos Pendientes Creados por mi.
				  3  : Documentos Firmados Creados por mi. 
EXEC [RH].[spBuscarEmpleadosTipo]@IDUsuario = 1, @query = null, @tipo = 2        
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

/*
	EXEC [FirmaDigital].[spBuscarDocumentos] @tipo = 3, @IDUsuario = 1
*/

CREATE   PROCEDURE [FirmaDigital].[spBuscarDocumentos](
	 @tipo  int = null
	,@ID Varchar(255) = null
	,@IDTipoDocumento int = 0
	,@ExternalId VARCHAR(255) = null
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'CreatedAt'
	,@orderDirection varchar(4) = 'desc'
)
AS
BEGIN
	SET FMTONLY OFF;

	IF(@tipo is null)
	BEGIN
		SET @tipo = 0
	END


	declare  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT
	   ,@Email VARCHAR(255) = null
       ,@ESTATUS_PENDING VARCHAR(15) = 'pending'
       ,@ESTATUS_COMPLETED VARCHAR(15) = 'completed'
       ,@LABEL_ESTATUS_PENDIG VARCHAR(25) 
       ,@LABEL_ESTATUS_COMPLETED VARCHAR(25) 
       ,@LABEL_REMIND_DIARIO VARCHAR(50) 
       ,@LABEL_REMIND_TRES   VARCHAR(50) 
       ,@LABEL_REMIND_SEMANAL VARCHAR(50) 
       ,@VARIANT_ESTATUS_PENDING VARCHAR(25) = 'warning'
       ,@VARIANT_ESTATUS_COMPLETED VARCHAR(25) = 'success'
       ,@NUMERO_DIAS_REMIND_DIARIO INT = 1
       ,@NUMERO_DIAS_REMIND_TRES   INT = 3
       ,@NUMERO_DIAS_REMIND_SEMANAL INT = 7
       
       ,@IDIdiomaTblIdiomas VARCHAR(5)
	;
	
	SELECT @Email = Email from Seguridad.tblUsuarios with(nolock) where IDUsuario = @IDUsuario    
	
    SELECT @IDIdiomaTblIdiomas=lower(replace(App.fnGetPreferencia('Idioma',@IDUsuario, 'esmx'), '-',''))

    SET @IDIdiomaTblIdiomas = CASE WHEN @IDIdiomaTblIdiomas='enus' THEN 'en-US' ELSE 'es-MX' END

        
    SELECT @LABEL_ESTATUS_PENDIG =  JSON_VALUE(Traduccion, '$.translate.LabelEstatusPendiente') 
          ,@LABEL_ESTATUS_COMPLETED = JSON_VALUE(Traduccion, '$.translate.LabelEstatusCompletado') 
          ,@LABEL_REMIND_DIARIO = JSON_VALUE(Traduccion, '$.translate.LabelRemindSemanal') 
          ,@LABEL_REMIND_TRES = JSON_VALUE(Traduccion, '$.translate.LabelRemindTresDias') 
          ,@LABEL_REMIND_SEMANAL = JSON_VALUE(Traduccion, '$.translate.LabelRemindSemanal') 
    FROM App.tblIdiomas
    WHERE IDIdioma = @IDIdiomaTblIdiomas;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'CreatedAt' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
  DECLARE @Result AS TABLE(
			Id  Varchar(255)
			,IDTipoDocumento int
			,TipoDocumento  Varchar(255)
			,Nombre  Varchar(255)			
			,ExternalId  Varchar(255)
			,MessageForSigners  Varchar(MAX)
			,RemindEvery int
			,RemindEveryLabel  Varchar(255)
			,OriginalHash  Varchar(255)
			,FileName  Varchar(MAX)
			,SignedByAll bit
			,Signed bit
			,SignedAt datetime
			,DaysToExpire int
            ,[ExpiresAt]  DATETIME
            ,[CreatedAt]          DATETIME            
			,IDUsuario int
			,Usuario  Varchar(255)
            ,UsuarioEmail Varchar(255)
			,CallbackUrl  Varchar(max)
			,SignCallbackUrl   Varchar(max)
			,[File]   Varchar(max)
			,FileDownload   Varchar(max)
			,FileSigned  Varchar(max)
			,FileSignedDownload  Varchar(max)
			,FileZipped  Varchar(max)
			,ManualClose bit
			,SendMail bit
			,State Varchar(255)
            ,StateLabel Varchar(255)
            ,StateLabelVariant Varchar(255)
  )



	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	IF(@tipo = -1)  -- -1 : Todos los Documentos
	BEGIN
		INSERT INTO @Result
		SELECT     
			 d.Id
			,isnull(d.IDTipoDocumento,0) as IDTipoDocumento
			,td.Descripcion as TipoDocumento
			,d.Nombre			
			,d.ExternalId
			,d.MessageForSigners
			,isnull(d.RemindEvery,0) as RemindEvery
			,CASE WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_DIARIO THEN @LABEL_REMIND_DIARIO
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_TRES THEN @LABEL_REMIND_TRES
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_SEMANAL THEN @LABEL_REMIND_SEMANAL
				  ELSE '' END AS RemindEveryLabel
			,d.OriginalHash
			,d.FileName
			,isnull(d.SignedByAll,0)as SignedByAll
			,isnull(d.Signed,0) as Signed
			,isnull(d.SignedAt,0) as SignedAt
			,isnull(d.DaysToExpire,0) as DaysToExpire
            ,d.ExpiresAt
            ,d.CreatedAt            
			,isnull(d.IDUsuario,0) as IDUsuario
			,U.Cuenta +' - '+ U.Nombre +' '+ U.Apellido as Usuario
            ,U.Email as UsuarioEmail
			,d.CallbackUrl
			,d.SignCallbackUrl
			,d.[File]
			,d.FileDownload
			,d.FileSigned
			,d.FileSignedDownload
			,d.FileZipped
			,isnull(d.ManualClose,0) as ManualClose
			,isnull(d.SendMail,0) as SendMail
			,d.State
            ,CASE WHEN d.State = @ESTATUS_PENDING THEN @LABEL_ESTATUS_PENDIG 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @LABEL_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabel
            ,CASE WHEN d.State = @ESTATUS_PENDING  THEN @VARIANT_ESTATUS_PENDING 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @VARIANT_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabelVariant     
		FROM [FirmaDigital].[TblDocumentos] d with(nolock)  
			left join [FirmaDigital].[TblCatTiposDocumentos] td with(nolock)
				on td.IDTipoDocumento = d.IDTipoDocumento
			left join [Seguridad].[tblUsuarios] U WIth(nolock)
				on U.IDUsuario = d.IDUsuario
		WHERE
			( 
				(d.id = @ID or isnull(@ID,'') ='')
				AND (d.IDTipoDocumento = @IDTipoDocumento or isnull(@IDTipoDocumento,0) =0)
				AND (d.ExternalId = @ExternalId or isnull(@ExternalId,'') ='')
			)  
			--and (@query = '""' or contains(d.*, @query)) 
	END
	
	IF(@tipo = 0) --  0  : Documentos Pendientes que Requieren Mi Firma
	BEGIN

		INSERT INTO @Result
		SELECT     
			 d.Id
			,isnull(d.IDTipoDocumento,0) as IDTipoDocumento
			,td.Descripcion as TipoDocumento
			,d.Nombre			
			,d.ExternalId
			,d.MessageForSigners
			,isnull(d.RemindEvery,0) as RemindEvery
			,CASE WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_DIARIO THEN @LABEL_REMIND_DIARIO
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_TRES THEN @LABEL_REMIND_TRES
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_SEMANAL THEN @LABEL_REMIND_SEMANAL
				  ELSE '' END AS RemindEveryLabel
			,d.OriginalHash
			,d.FileName
			,isnull(d.SignedByAll,0)as SignedByAll
			,isnull(d.Signed,0) as Signed
			,isnull(d.SignedAt,0) as SignedAt
			,isnull(d.DaysToExpire,0) as DaysToExpire
            ,d.ExpiresAt
            ,d.CreatedAt            
			,isnull(d.IDUsuario,0) as IDUsuario
			,U.Cuenta +' - '+ U.Nombre +' '+ U.Apellido as Usuario
            ,U.Email as UsuarioEmail
			,d.CallbackUrl
			,d.SignCallbackUrl
			,d.[File]
			,d.FileDownload
			,d.FileSigned
			,d.FileSignedDownload
			,d.FileZipped
			,isnull(d.ManualClose,0) as ManualClose
			,isnull(d.SendMail,0) as SendMail
			,d.State
             ,CASE WHEN d.State = @ESTATUS_PENDING THEN @LABEL_ESTATUS_PENDIG 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @LABEL_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabel
            ,CASE WHEN d.State = @ESTATUS_PENDING  THEN @VARIANT_ESTATUS_PENDING 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @VARIANT_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabelVariant     
		FROM [FirmaDigital].[TblDocumentos] d with(nolock)  
			left join [FirmaDigital].[TblCatTiposDocumentos] td with(nolock)
				on td.IDTipoDocumento = d.IDTipoDocumento
			left join [Seguridad].[tblUsuarios] U WIth(nolock)
				on U.IDUsuario = d.IDUsuario
		WHERE
			( 
				(d.id = @ID or isnull(@ID,'') ='')
				AND (d.IDTipoDocumento = @IDTipoDocumento or isnull(@IDTipoDocumento,0) =0)
				AND (d.ExternalId = @ExternalId or isnull(@ExternalId,'') ='')
				AND (d.ID in (SELECT ID from FirmaDigital.tblDocumentosFirmantes with(nolock) WHERE Email = @Email and isnull(Signed,0) = 0))
				AND (isnull(d.Signed,0) = 0)
			)  
			--and (@query = '""' or contains(d.*, @query)) 
	END

	IF(@tipo = 1) --  1  : Documentos Firmados que ya Firme.
	BEGIN

		INSERT INTO @Result
		SELECT     
			 d.Id
			,isnull(d.IDTipoDocumento,0) as IDTipoDocumento
			,td.Descripcion as TipoDocumento
			,d.Nombre			
			,d.ExternalId
			,d.MessageForSigners
			,isnull(d.RemindEvery,0) as RemindEvery
            ,CASE WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_DIARIO THEN @LABEL_REMIND_DIARIO
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_TRES THEN @LABEL_REMIND_TRES
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_SEMANAL THEN @LABEL_REMIND_SEMANAL
				  ELSE '' END AS RemindEveryLabel
			,d.OriginalHash
			,d.FileName
			,isnull(d.SignedByAll,0)as SignedByAll
			,isnull(d.Signed,0) as Signed
			,isnull(d.SignedAt,0) as SignedAt
			,isnull(d.DaysToExpire,0) as DaysToExpire
            ,d.ExpiresAt
            ,d.CreatedAt            
			,isnull(d.IDUsuario,0) as IDUsuario
			,U.Cuenta +' - '+ U.Nombre +' '+ U.Apellido as Usuario
			,U.Email as UsuarioEmail
            ,d.CallbackUrl
			,d.SignCallbackUrl
			,d.[File]
			,d.FileDownload
			,d.FileSigned
			,d.FileSignedDownload
			,d.FileZipped
			,isnull(d.ManualClose,0) as ManualClose
			,isnull(d.SendMail,0) as SendMail
			,d.State
             ,CASE WHEN d.State = @ESTATUS_PENDING THEN @LABEL_ESTATUS_PENDIG 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @LABEL_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabel
            ,CASE WHEN d.State = @ESTATUS_PENDING  THEN @VARIANT_ESTATUS_PENDING 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @VARIANT_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabelVariant     
		FROM [FirmaDigital].[TblDocumentos] d with(nolock)  
			left join [FirmaDigital].[TblCatTiposDocumentos] td with(nolock)
				on td.IDTipoDocumento = d.IDTipoDocumento
			left join [Seguridad].[tblUsuarios] U WIth(nolock)
				on U.IDUsuario = d.IDUsuario
		WHERE
			( 
				(d.id = @ID or isnull(@ID,'') ='')
				AND (d.IDTipoDocumento = @IDTipoDocumento or isnull(@IDTipoDocumento,0) =0)
				AND (d.ExternalId = @ExternalId or isnull(@ExternalId,'') ='')
				AND (d.ID in (SELECT ID from FirmaDigital.tblDocumentosFirmantes with(nolock) WHERE Email = @Email and isnull(Signed,0) = 1))
				AND (isnull(d.Signed,0) = 1)
			)  
			--and (@query = '""' or contains(d.*, @query)) 
	END

	IF(@tipo = 2) --  2  : Documentos Pendientes Creados por mi.
	BEGIN

		INSERT INTO @Result
		SELECT     
			 d.Id
			,isnull(d.IDTipoDocumento,0) as IDTipoDocumento
			,td.Descripcion as TipoDocumento
			,d.Nombre			
			,d.ExternalId
			,d.MessageForSigners
			,isnull(d.RemindEvery,0) as RemindEvery
			,CASE WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_DIARIO THEN @LABEL_REMIND_DIARIO
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_TRES THEN @LABEL_REMIND_TRES
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_SEMANAL THEN @LABEL_REMIND_SEMANAL
				  ELSE '' END AS RemindEveryLabel
			,d.OriginalHash
			,d.FileName
			,isnull(d.SignedByAll,0)as SignedByAll
			,isnull(d.Signed,0) as Signed
			,isnull(d.SignedAt,0) as SignedAt
			,isnull(d.DaysToExpire,0) as DaysToExpire
            ,d.ExpiresAt
            ,d.CreatedAt            
			,isnull(d.IDUsuario,0) as IDUsuario
			,U.Cuenta +' - '+ U.Nombre +' '+ U.Apellido as Usuario
            ,U.Email as UsuarioEmail
			,d.CallbackUrl
			,d.SignCallbackUrl
			,d.[File]
			,d.FileDownload
			,d.FileSigned
			,d.FileSignedDownload
			,d.FileZipped
			,isnull(d.ManualClose,0) as ManualClose
			,isnull(d.SendMail,0) as SendMail
			,d.State
             ,CASE WHEN d.State = @ESTATUS_PENDING THEN @LABEL_ESTATUS_PENDIG 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @LABEL_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabel
            ,CASE WHEN d.State = @ESTATUS_PENDING  THEN @VARIANT_ESTATUS_PENDING 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @VARIANT_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabelVariant     
		FROM [FirmaDigital].[TblDocumentos] d with(nolock)  
			left join [FirmaDigital].[TblCatTiposDocumentos] td with(nolock)
				on td.IDTipoDocumento = d.IDTipoDocumento
			left join [Seguridad].[tblUsuarios] U WIth(nolock)
				on U.IDUsuario = d.IDUsuario
		WHERE
			( 
				(d.id = @ID or isnull(@ID,'') ='')
				AND (d.IDTipoDocumento = @IDTipoDocumento or isnull(@IDTipoDocumento,0) =0)
				AND (d.ExternalId = @ExternalId or isnull(@ExternalId,'') ='')
				AND (isnull(d.IDUsuario,0) = @IDUsuario)
				AND (isnull(d.Signed,0) = 0)
			)  
			--and (@query = '""' or contains(d.*, @query)) 
	END

	IF(@tipo = 3) --  3  : Documentos Firmados Creados por mi. 
	BEGIN

		INSERT INTO @Result
		SELECT     
			 d.Id
			,isnull(d.IDTipoDocumento,0) as IDTipoDocumento
			,td.Descripcion as TipoDocumento
			,d.Nombre			
			,d.ExternalId
			,d.MessageForSigners
			,isnull(d.RemindEvery,0) as RemindEvery
			,CASE WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_DIARIO THEN @LABEL_REMIND_DIARIO
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_TRES THEN @LABEL_REMIND_TRES
				  WHEN ISNULL(d.RemindEvery,0) = @NUMERO_DIAS_REMIND_SEMANAL THEN @LABEL_REMIND_SEMANAL
				  ELSE '' END AS RemindEveryLabel
			,d.OriginalHash
			,d.FileName
			,isnull(d.SignedByAll,0)as SignedByAll
			,isnull(d.Signed,0) as Signed
			,isnull(d.SignedAt,0) as SignedAt
			,isnull(d.DaysToExpire,0) as DaysToExpire
            ,d.ExpiresAt
            ,d.CreatedAt            
			,isnull(d.IDUsuario,0) as IDUsuario
			,U.Cuenta +' - '+ U.Nombre +' '+ U.Apellido as Usuario
            ,U.Email as UsuarioEmail
			,d.CallbackUrl
			,d.SignCallbackUrl
			,d.[File]
			,d.FileDownload
			,d.FileSigned
			,d.FileSignedDownload
			,d.FileZipped
			,isnull(d.ManualClose,0) as ManualClose
			,isnull(d.SendMail,0) as SendMail
			,d.State
             ,CASE WHEN d.State = @ESTATUS_PENDING THEN @LABEL_ESTATUS_PENDIG 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @LABEL_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabel
            ,CASE WHEN d.State = @ESTATUS_PENDING  THEN @VARIANT_ESTATUS_PENDING 
                  WHEN d.state = @ESTATUS_COMPLETED THEN @VARIANT_ESTATUS_COMPLETED
                  ELSE '' END AS StateLabelVariant     
		FROM [FirmaDigital].[TblDocumentos] d with(nolock)  
			left join [FirmaDigital].[TblCatTiposDocumentos] td with(nolock)
				on td.IDTipoDocumento = d.IDTipoDocumento
			left join [Seguridad].[tblUsuarios] U WIth(nolock)
				on U.IDUsuario = d.IDUsuario
		WHERE
			( 
				(d.id = @ID or isnull(@ID,'') ='')
				AND (d.IDTipoDocumento = @IDTipoDocumento or isnull(@IDTipoDocumento,0) =0)
				AND (d.ExternalId = @ExternalId or isnull(@ExternalId,'') ='')
				AND (isnull(d.IDUsuario,0) = @IDUsuario)
				AND (isnull(d.Signed,0) = 1)
			)  
			--and (@query = '""' or contains(d.*, @query)) 
	END

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @Result

	select @TotalRegistros = COUNT(ID) from @Result		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from @Result
	order by 
		case when @orderByColumn = 'CreatedAt'			and @orderDirection = 'asc'		then CreatedAt end,			
		case when @orderByColumn = 'CreatedAt'			and @orderDirection = 'desc'	then CreatedAt end desc,		
		Nombre asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
