USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	
-- =============================================
CREATE PROCEDURE [RH].[spIPlazasImportacion]
    -- Add the parameters for the stored procedure here	
    @dtImportacionPlazas [RH].[dtImportacionPlazas] READONLY,
    @IDCliente int ,    
    @IDUsuario int ,
    @Filtro varchar(255),
    @IDReferencia int 
AS
BEGIN
    declare @currentRow int

	declare @tempNewsPlazas as table(
		IDPlaza int, 
		IDCliente int,
		Cliente varchar(max),
		Codigo varchar(20),
		ParentId int,
		ParentCodigo varchar(20),
		TotalPosiciones int, 
		PosicionesDisponibles int,
		PosicionesOcupadas int, 
        PosicionesCanceladas int,
		IDEstatusPlaza int,
		IDEstatus int,
		Estatus varchar(max),
		IDUsuario int,
		FechaRegEstatus datetime, 
		Configuraciones varchar(max),
		IDPuesto int, 
		Puesto varchar(max),
		ConfiguracionStatus varchar(max),		
        IDNivelSalarial int,
        NombreNivelSalarial varchar(100),
        NivelSalarial int,
        DescripcionPublicaVacante varchar(max),
        EsAsistente bit,        
        IDNivelEmpresarial int ,
        NombreNivelEmpresarial varchar(255),
        OrdenNivelEmpresarial int,
        TotalPaginas int ,
        TotalRows int
	)

    declare @dtIdentity as Table (
        IDPlazaImportacion int,
        IDPlazaIdentity int
    )

    declare @dtPosiciones as Table (
        IDPlaza int,
        IDPosicion int,
        RowNumber int
    )

    

    select @currentRow=min(RowNumber) From @dtImportacionPlazas 


    WHILE exists(select top 1 1 
				from @dtImportacionPlazas
				where RowNumber >= @currentRow)
    BEGIN
        DECLARE @IDPlazaImportacion int = 0,	            	            
                @IDPlazaIdentity int =0 ,
                @IDPuesto int,
                @ParentId int,
                @FechaInicial date,               
                @IDPosicionJefe int , 
                @PosicionesJefe varchar(max) ,
                @PosicionesJefeCodigo varchar(max) ,
                @FechaFin date,
                @IsTemporal bit,
                @EsAsistente bit,
                @IDNivelSalarial int,	    
                @IDNivelEmpresarial INT ,                        
                @CantidadPosiciones int ,                                
                @ConfiguracionJson varchar(max);

        SELECT
            @IDPlazaImportacion = iplaza.IDPlaza,
            @IDPuesto =  p.IDPuesto,
            @IDNivelSalarial=iplaza.IDNivelSalarial,
            @IsTemporal=iplaza.IsTemporal,
            @FechaInicial=iplaza.FechaInicio,
            @FechaFin=iplaza.FechaFin,
            @IDNivelEmpresarial=iplaza.IDNivelEmpresarial,
            @ConfiguracionJson=iplaza.ConfiguracionJson,
            @PosicionesJefe =isnull(iplaza.PosicionesJefes,''),
            @PosicionesJefeCodigo =isnull(iplaza.PosicionesJefesCodigo,''),
            @EsAsistente=iplaza.EsAsistente,                             
            @ParentId= case when iplaza.ParentID = 0  and isnull(iplaza.ParentCodigo, '') = ''
                                then 0
                            when isnull(iplaza.ParentCodigo,'') <> ''                 
                                then tP.IDPlaza                            
                            else isnull(iplaza.ParentID,0)
                end,             
            @CantidadPosiciones=iplaza.CantidadPosiciones
        FROM @dtImportacionPlazas iplaza
            INNER JOIN rh.tblCatPuestos p	on p.Codigo =iplaza.CodigoPuesto
            LEFT JOIN @dtIdentity i			on i.IDPlazaImportacion = iplaza.ParentID                       
            left join rh.tblCatPlazas tP	on tP.Codigo=iplaza.ParentCodigo
        where RowNumber=@currentRow

        IF ISNULL(@PosicionesJefe, '0') = '0' 
        BEGIN
            SELECT @IDPosicionJefe=0
            select @ConfiguracionJson=REPLACE(@ConfiguracionJson,'%idposicionjefe%',cast(@IDPosicionJefe as varchar(10))) 
        END ELSE if(ISNULL(@PosicionesJefe, '') <> '')
        BEGIN 
            SELECT @IDPosicionJefe=IDPosicion fROM ( 
                    select IDPosicion, ROW_NUMBER()over(order by IDPosicion) rownumber From rh.tblCatPosiciones
                    where IDPlaza=@ParentId 
            ) AS tabla where rownumber=@PosicionesJefe

            select @ConfiguracionJson=REPLACE(@ConfiguracionJson,'%idposicionjefe%',cast(@IDPosicionJefe as varchar(10))) 
        END ELSE
        BEGIN                                 
            select @IDPosicionJefe = IDPosicion from rh.tblCatPosiciones where Codigo=@PosicionesJefeCodigo                
            select @ConfiguracionJson=REPLACE(@ConfiguracionJson,'%idposicionjefe%',cast(@IDPosicionJefe as varchar(10))) 
        END


        

        IF @IDNivelEmpresarial >0  
        begin 
            
            insert @tempNewsPlazas
            EXEC [RH].[spIUPlaza]
            @IDPlaza	= 0,
            @IDCliente	= @IDCliente,	                
            @IDPuesto	= @IDPuesto,
            @ParentId	= @ParentId,
            @IDNivelSalarial		= @IDNivelSalarial,            
            @IDNivelEmpresarial=@IDNivelEmpresarial,
            @EsAsistente=@EsAsistente,
            @IDUsuario	= @IDUsuario,
            @ConfiguracionesJson= @ConfiguracionJson,
            @ReiniciarUnidad	= 0,
            @DescripcionPublicaVacante='',
            @Filtro=@Filtro,
            @IDReferencia=@IDReferencia                
        end
        else 
        BEGIN
        
            insert @tempNewsPlazas
            EXEC [RH].[spIUPlaza]
            @IDPlaza	= 0,
            @IDCliente	= @IDCliente,	                
            @IDPuesto	= @IDPuesto,
            @ParentId	= @ParentId,
            @IDNivelSalarial		= @IDNivelSalarial,  
            @EsAsistente=@EsAsistente,
            @IDUsuario	= @IDUsuario,
            @ConfiguracionesJson= @ConfiguracionJson,
            @ReiniciarUnidad	= 0,
            @DescripcionPublicaVacante='',
            @Filtro=@Filtro,
            @IDReferencia=@IDReferencia                
        END

		
        SELECT @IDPlazaIdentity=max(IDPlaza) from rh.tblCatPlazas
                
		set @FechaFin = case when isnull(@IsTemporal, 0) = 0 then null else @FechaFin end

        EXEC [RH].[spSolicitarNuevasPosiciones]
            @IDPlaza			= @IDPlazaIdentity ,
            @DisponibleDesde	= @FechaInicial,
            @DisponibleHasta	= @FechaFin,
            @CantidadPosiciones = @CantidadPosiciones,
            @Temporal			= @IsTemporal,
            @IDEstatusPosicion	= 2,
            @IDUsuario			= @IDUsuario

        INSERT INTO @dtIdentity (IDPlazaImportacion,IDPlazaIdentity)  
		VALUES (@IDPlazaImportacion,@IDPlazaIdentity)                                
        
		select @currentRow=min(RowNumber) 
		From @dtImportacionPlazas 
		where RowNumber > @currentRow
    END 
            
    select *
	from @dtIdentity
END
GO
