USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: Jose Vargas
** Email			: Jvargas@adagio.com.mx
** FechaCreacion	: 2023-09-10
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarChatMensajes] ( 
    -- @IDUsuario int, 
    -- @IDTipoUsuario int,
    
    @IDSala int
    ,@IDChatMensaje  int=0
    ,@LastIDChatMensaje int =0
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'IDChatMensaje'
    ,@orderDirection varchar(4) = 'desc'    
)  AS  

BEGIN  

	SET FMTONLY OFF;
	declare 
	 @TotalPaginas int = 0
	 ,@TotalRegistros decimal(18,2) = 0.00
	 ,	@IDIdioma varchar(20);
    
    set @PageNumber= IIF( ISNULL(@PageNumber,0)=0,1,@PageNumber );
    set @PageSize= IIF( ISNULL(@PageSize,0)=0,2147483647,@PageSize );
    set @orderByColumn= IIF( ISNULL(@orderByColumn,'')='','IDChatMensaje',@orderByColumn );
    set @orderDirection= IIF( ISNULL(@orderByColumn,'')='','desc',@orderDirection );



    declare @tempResponse as table (    				
        IDChatMensaje int ,
        IDSala int NOT NULL,
        IDUsuario int NOT NULL,
        IDTipoUsuario int NOT NULL,
        Mensaje NVARCHAR (MAX) NULL,        
        NombreCompleto varchar(255),
        Foto varchar(255),        
        [FechaHora]        DATETIME   
	);

	insert @tempResponse  ([IDChatMensaje],[IDSala], [IDUsuario], [IDTipoUsuario], [Mensaje], [FechaHora])
    SELECT * FROM Reclutamiento.tblChatMensajes where     
    ( IDSala=@IDSala and (isnull(@LastIDChatMensaje,0)=0 OR IDChatMensaje>@LastIDChatMensaje) )


    update temp  set NombreCompleto=concat(candidato.Nombre,' ',candidato.Paterno) , Foto=CONCAT('/Fotos/candidatos/',temp.IDUsuario,'.jpg')
        from @tempResponse temp
    inner join Reclutamiento.tblCandidatos candidato on candidato.IDCandidato=temp.IDUsuario
        Where IDTipoUsuario=1

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDChatMensaje) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'IDChatMensaje'			and @orderDirection = 'asc'		then IDChatMensaje end,			
		case when @orderByColumn = 'IDChatMensaje'			and @orderDirection = 'desc'	then IDChatMensaje end desc,					
		IDChatMensaje asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
