USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tzdb].[Links](
	[LinkZoneId] [int] NOT NULL,
	[CanonicalZoneId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LinkZoneId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tzdb].[Links]  WITH CHECK ADD  CONSTRAINT [FK_Links_Zones_1] FOREIGN KEY([LinkZoneId])
REFERENCES [Tzdb].[Zones] ([Id])
GO
ALTER TABLE [Tzdb].[Links] CHECK CONSTRAINT [FK_Links_Zones_1]
GO
ALTER TABLE [Tzdb].[Links]  WITH CHECK ADD  CONSTRAINT [FK_Links_Zones_2] FOREIGN KEY([CanonicalZoneId])
REFERENCES [Tzdb].[Zones] ([Id])
GO
ALTER TABLE [Tzdb].[Links] CHECK CONSTRAINT [FK_Links_Zones_2]
GO
