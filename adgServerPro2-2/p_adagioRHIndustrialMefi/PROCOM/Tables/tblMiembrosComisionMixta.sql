USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblMiembrosComisionMixta](
	[IDMiembroComisionMixta] [int] IDENTITY(1,1) NOT NULL,
	[IDClienteComisionMixta] [int] NOT NULL,
	[IDCatTipoMiembroComisionMixta] [int] NOT NULL,
	[NombreCompleto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Puesto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIngreso] [date] NULL,
	[IMSS] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIMSS] [date] NULL,
 CONSTRAINT [PK_ProcomtblMiembrosComisionMixta_IDMiembroComisionMixta] PRIMARY KEY CLUSTERED 
(
	[IDMiembroComisionMixta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblMiembrosComisionMixta]  WITH CHECK ADD  CONSTRAINT [FK_ProcomtblClienteComisionMixta_ProcomtblMiembrosComisionMixta_IDClienteComisionMixta] FOREIGN KEY([IDClienteComisionMixta])
REFERENCES [PROCOM].[tblClienteComisionMixta] ([IDClienteComisionMixta])
GO
ALTER TABLE [PROCOM].[tblMiembrosComisionMixta] CHECK CONSTRAINT [FK_ProcomtblClienteComisionMixta_ProcomtblMiembrosComisionMixta_IDClienteComisionMixta]
GO
ALTER TABLE [PROCOM].[tblMiembrosComisionMixta]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatTipoMiembroComisionMixta_ProcomtblMiembrosComisionMixta_IDCatTipoMiembroComisionMixta] FOREIGN KEY([IDCatTipoMiembroComisionMixta])
REFERENCES [PROCOM].[TblCatTipoMiembroComisionMixta] ([IDCatTipoMiembroComisionMixta])
GO
ALTER TABLE [PROCOM].[tblMiembrosComisionMixta] CHECK CONSTRAINT [FK_RHTblCatTipoMiembroComisionMixta_ProcomtblMiembrosComisionMixta_IDCatTipoMiembroComisionMixta]
GO
