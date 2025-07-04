USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: <Autor,varchar,Nombre>
** Email			: <Email,varchar,@adagio.com.mx>
** FechaCreacion	: <FechaCreacion,Date,Fecha>
** Paremetros		:              

	--Estatus de posiciones				
	-- 1 - 'Pendiente de autorización'
	-- 2 - 'Autorizada/Disponible'	
	-- 3 - 'Ocupada'					
	-- 4 - 'Cancelada'				
	-- 5 - 'No autorizada'	

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
 /*exec [RH].[spSolicitarNuevasPosiciones] @IDPlaza=107,@DisponibleDesde='2022-05-05' ,@DisponibleHasta=null,@CantidadPosiciones=1,@Temporal=0,@IDUsuario=1
 
 select * From rh.tblCatPosiciones
 select * From rh.tblEstatusPosiciones

 select * From rh.tblCatPlazas*/
CREATE proc [RH].[spSolicitarNuevasPosiciones](
	@IDPlaza int,
	@DisponibleDesde date = null,
	@DisponibleHasta date = null,
	@CantidadPosiciones int = 1,
	@Temporal int = 0,
    @IDEstatusPosicion int =1,
	@IDUsuario int
) as

	declare 
		@IDTipoCatalogoEstatusPlazas int = 5,
		@IDPosicionJefe int,
		@IDCliente int,
		@IDPosicion int,
		@MAXClaveID  int = 0,
		@Longitud int = 4,  
		@Prefijo varchar(10) ,
        @PrefijoPosicion varchar(3)
	;

    set @PrefijoPosicion='PO_'

    declare @IDOrganigrama int
	select 
		@IDCliente = p.IDCliente,
		@IDOrganigrama = p.IDOrganigrama
	from RH.tblCatPlazas p
		-- join RH.tblCatClientes c on c.IDCliente = p.IDCliente
	where p.IDPlaza = @IDPlaza

    select @Prefijo=Prefijo 
    from rh.tblCatOrganigramas  oo
		inner join Seguridad.tblCatTiposFiltros tt on tt.Filtro=oo.Filtro 
    where oo.IDOrganigrama=@IDOrganigrama


	select @MAXClaveID = isnull(MAX(cast(REPLACE(REPLACE(p.Codigo, isnull(@Prefijo,''),''),@PrefijoPosicion,'') as int)),0)  
	from RH.tblCatPosiciones p  with(nolock)   		
		inner join rh.tblCatPlazas pl on pl.IDPlaza=p.IDPlaza and pl.IDOrganigrama=@IDOrganigrama
    
	
	Set @MAXClaveID = isnull(@MAXClaveID,0) + 1  

    declare @json varchar(max)

    select @json=Configuraciones   from rh.tblCatPlazas where IDPlaza=@IDPlaza

    SELECT @IDPosicionJefe=Valor
        FROM OPENJSON(@json )
        WITH (   
            IDTipoConfiguracionPlaza   varchar(200) '$.IDTipoConfiguracionPlaza' ,                
            Valor int	'$.Valor'  
        ) 
    where IDTipoConfiguracionPlaza='PosicionJefe'

    
	/*  Comentado 
    select top 1 @IDPosicionJefe = Valor
	from RH.tblConfiguracionesPlazas
	where IDPlaza = @IDPlaza and IDTipoConfiguracionPlaza = 'PosicionJefe'*/

    
	
	declare @archive as table (
		ActionType VARCHAR(50),
		IDPosicion int
	);

	declare @tempNuevasPosiciones as table (
		ID int,
		IDCliente int, 
		IDPlaza int, 
		Codigo App.SMName,
		ParentId int,
		Temporal bit        
	);

	;WITH cteIDsNuevasPosiciones ( ID, Codigo ) AS (
		select 1, isnull(@MAXClaveID,0) 
		union ALL
		select 1 + ID, Codigo + 1 FROM cteIDsNuevasPosiciones 
		where ID < @CantidadPosiciones
	)

	 insert @tempNuevasPosiciones(ID,IDCliente, IDPlaza, Codigo, ParentId, Temporal)
	SELECT 
		ID, 
		@IDCliente, 
		@IDPlaza, 
		@PrefijoPosicion+isnull(@Prefijo,'')+REPLICATE('0',@Longitud - LEN(RTRIM(cast(Codigo as varchar)))) + cast(Codigo as Varchar),
		ISNULL(@IDPosicionJefe, 0), 
		@Temporal        
	from cteIDsNuevasPosiciones;

	update @tempNuevasPosiciones
		set 
			Codigo = SUBSTRING(Codigo, 1, 9)
            

	--select * from @tempNuevasPosiciones
	BEGIN TRY
		BEGIN TRAN TransNuevasPosiciones
			MERGE [RH].[tblCatPosiciones] AS TARGET
			USING @tempNuevasPosiciones as SOURCE
				on SOURCE.ID = -1			
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDCliente,IDPlaza,Codigo, ParentId, Temporal,DisponibleDesde,DisponibleHasta, UUID)
				values(SOURCE.IDCliente,SOURCE.IDPlaza, SOURCE.Codigo, SOURCE.ParentId, SOURCE.Temporal,@DisponibleDesde,@DisponibleHasta, NEWID())
			OUTPUT
			$action AS ActionType,
			inserted.IDPosicion
			INTO @archive;
		COMMIT TRAN TransNuevasPosiciones			
	END TRY
	BEGIN CATCH
	select 
		ERROR_MESSAGE() as ErrorMessage,
		ERROR_LINE() as ErrorLine,
		@IDPlaza as IDPlaza
		ROLLBACK TRAN TransNuevasPosiciones
	END CATCH

	insert [RH].[tblEstatusPosiciones](IDPosicion,IDEstatus, DisponibleDesde, DisponibleHasta, IDUsuario)
	select IDPosicion, @IDEstatusPosicion, @DisponibleDesde, @DisponibleHasta, @IDUsuario
	from @archive

	select @IDPosicion = MIN(IDPosicion) from @archive

	/*while exists(select top 1 1 from @archive where IDPosicion >= @IDPosicion)
	begin
		exec [RH].[spIAprobadoresPosiciones]
			@IDPlaza = @IDPlaza,
			@IDPosicion = @IDPosicion,
			@IDUsuario = @IDUsuario

		select @IDPosicion = MIN(IDPosicion) from @archive where IDPosicion > @IDPosicion
	end*/

	exec [RH].[spActualizarTotalesPosiciones] @IDPlaza = @IDPlaza, @IDUsuario = @IDUsuario	
	---- Iniciar proceso de autorización
GO
