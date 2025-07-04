USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[TblClienteHonorarios](
	[IDClienteHonorario] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[Porcentaje] [decimal](18, 4) NULL,
	[IncluyeIVA] [bit] NULL,
 CONSTRAINT [PK_ProcomTblClienteHonorarios_IDClienteHonorario] PRIMARY KEY CLUSTERED 
(
	[IDClienteHonorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [u_ProcomTblClienteHonorarios_IDCliente] ON [PROCOM].[TblClienteHonorarios]
(
	[IDCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[TblClienteHonorarios] ADD  CONSTRAINT [d_ProcomTblClienteHonorarios_Porcentaje]  DEFAULT ((0)) FOR [Porcentaje]
GO
ALTER TABLE [PROCOM].[TblClienteHonorarios] ADD  CONSTRAINT [d_ProcomTblClienteHonorarios_IncluyeIVA]  DEFAULT ((1)) FOR [IncluyeIVA]
GO
ALTER TABLE [PROCOM].[TblClienteHonorarios]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteHonorarios_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[TblClienteHonorarios] CHECK CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteHonorarios_IDCliente]
GO
