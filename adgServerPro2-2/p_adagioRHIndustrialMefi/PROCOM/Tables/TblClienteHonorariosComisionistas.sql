USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[TblClienteHonorariosComisionistas](
	[IDClienteHonorarioComisionista] [int] IDENTITY(1,1) NOT NULL,
	[IDClienteHonorario] [int] NOT NULL,
	[IDCatComisionista] [int] NOT NULL,
	[Porcentaje] [decimal](18, 4) NULL,
 CONSTRAINT [PK_ProcomTblClienteHonorariosComisionistas_IDClienteHonorarioComisionista] PRIMARY KEY CLUSTERED 
(
	[IDClienteHonorarioComisionista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_ProcomTblClienteHonorariosComisionistas] ON [PROCOM].[TblClienteHonorariosComisionistas]
(
	[IDClienteHonorario] ASC,
	[IDCatComisionista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[TblClienteHonorariosComisionistas]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatComisionistas_ProcomClienteHonorariosComisionistas] FOREIGN KEY([IDCatComisionista])
REFERENCES [Nomina].[tblCatComisionistas] ([IDCatComisionista])
GO
ALTER TABLE [PROCOM].[TblClienteHonorariosComisionistas] CHECK CONSTRAINT [FK_NominaTblCatComisionistas_ProcomClienteHonorariosComisionistas]
GO
ALTER TABLE [PROCOM].[TblClienteHonorariosComisionistas]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblClienteHonorarios_ProcomTblClienteHonorariosComisionistas_IDClienteHonorario] FOREIGN KEY([IDClienteHonorario])
REFERENCES [PROCOM].[TblClienteHonorarios] ([IDClienteHonorario])
GO
ALTER TABLE [PROCOM].[TblClienteHonorariosComisionistas] CHECK CONSTRAINT [FK_ProcomTblClienteHonorarios_ProcomTblClienteHonorariosComisionistas_IDClienteHonorario]
GO
